from __future__ import annotations

from statistics import mean


class KMeansPlaytimeClusterer:
    PLAYER_TYPES = ["schnelle Spieler", "Standard-Spieler", "langsame Spieler"]
    RANDOM_STATE = 42
    INIT = "k-means++"
    N_INIT = "auto"
    MAX_ITER = 300
    TOL = 1e-4
    ALGORITHM = "lloyd"
    DEFAULT_FEATURES = ["playtime_minutes"]

    def __init__(self) -> None:
        self._sklearn = None

    def cluster_playtimes(
        self,
        playtimes: list[dict[str, float]],
        final_k: int = 3,
        max_k: int = 10,
        *,
        feature_keys: list[str] | None = None,
    ) -> tuple[list[dict[str, float | int | str]] | None, list[dict[str, float]]]:
        feature_keys = feature_keys or self.DEFAULT_FEATURES
        valid = self._valid_playtimes(playtimes)
        if not valid:
            print("  Keine gültigen Zeitwerte gefunden K-Means wird übersprungen.")
            return None, []

        sklearn = self._import_sklearn()
        if sklearn is None:
            return None, []

        max_k = max(1, min(max_k, len(valid)))

        if len(valid) < final_k:
            print(f"  Zu wenige Sessions für K-Means mit {final_k} Clustern. Mindestens {final_k} Sessions erforderlich.")
            return None, self.compute_elbow(valid, max_k, sklearn, feature_keys=feature_keys)

        elbow_data = self.compute_elbow(valid, max_k, sklearn, feature_keys=feature_keys)

        X, scaler = self._build_feature_matrix(valid, feature_keys, sklearn)
        model = self._build_kmeans(sklearn["KMeans"], final_k)
        labels = model.fit_predict(X)

        centroids = scaler.inverse_transform(model.cluster_centers_)
        # rank clusters by total centroid value (sum across selected features)
        centroid_sums = [float(row.sum()) for row in centroids]
        sorted_cluster_ids = sorted(range(len(centroid_sums)), key=lambda idx: centroid_sums[idx])
        cluster_rank = {cluster_id: rank for rank, cluster_id in enumerate(sorted_cluster_ids)}

        enriched: list[dict[str, float | int | str]] = []
        for index, row in enumerate(valid):
            raw_cluster = int(labels[index])
            rank = cluster_rank[raw_cluster]
            player_type = self.PLAYER_TYPES[rank] if rank < len(self.PLAYER_TYPES) else f"cluster_{rank}"
            enriched.append({**row, "cluster_id": rank, "player_type": player_type})
        return enriched, elbow_data

    def compute_elbow(
        self,
        playtimes: list[dict[str, float]],
        max_k: int,
        sklearn: dict[str, object] | None = None,
        *,
        feature_keys: list[str] | None = None,
    ) -> list[dict[str, float]]:
        sklearn = sklearn or self._import_sklearn()
        if sklearn is None or not playtimes:
            return []
        feature_keys = feature_keys or self.DEFAULT_FEATURES
        valid = self._valid_playtimes(playtimes)
        if not valid:
            return []
        max_k = max(1, min(max_k, len(valid)))
        X, _ = self._build_feature_matrix(valid, feature_keys, sklearn)
        elbow_data: list[dict[str, float]] = []
        for k in range(1, max_k + 1):
            model = self._build_kmeans(sklearn["KMeans"], k)
            model.fit(X)
            elbow_data.append({"k": float(k), "inertia": float(model.inertia_)})
        return elbow_data

    def build_cluster_summary(self, enriched: list[dict[str, float | int | str]], feature_keys: list[str] | None = None) -> list[dict[str, float | int | str]]:
        if not enriched:
            return []
        feature_keys = feature_keys or [k for k in self.DEFAULT_FEATURES if k in enriched[0]]
        summary: list[dict[str, float | int | str]] = []
        max_cluster_id = max(int(row["cluster_id"]) for row in enriched)
        for cluster_id in range(max_cluster_id + 1):
            rows = [row for row in enriched if int(row["cluster_id"]) == cluster_id]
            if not rows:
                continue
            entry: dict[str, float | int | str] = {
                "cluster_id": cluster_id,
                "player_type": self.PLAYER_TYPES[cluster_id] if cluster_id < len(self.PLAYER_TYPES) else f"cluster_{cluster_id}",
                "count": len(rows),
            }
            for feature in feature_keys:
                values = [float(row.get(feature, 0.0)) for row in rows]
                entry[f"min_{feature}"] = round(min(values), 4)
                entry[f"max_{feature}"] = round(max(values), 4)
                entry[f"avg_{feature}"] = round(mean(values), 4)
            summary.append(entry)
        return summary

    def _import_sklearn(self) -> dict[str, object] | None:
        if self._sklearn is not None:
            return self._sklearn
        try:
            from sklearn.cluster import KMeans
            from sklearn.preprocessing import StandardScaler
        except ImportError:
            self._sklearn = None
            return None
        self._sklearn = {"KMeans": KMeans, "StandardScaler": StandardScaler}
        return self._sklearn

    @staticmethod
    def _valid_playtimes(playtimes: list[dict[str, float]]) -> list[dict[str, float]]:
        return [row for row in playtimes if float(row.get("playtime_minutes", 0)) > 0]

    @staticmethod
    def _scale_playtimes(
        playtimes: list[dict[str, float]],
        sklearn: dict[str, object],
    ) -> tuple[object, object]:
        values = [[float(row["playtime_minutes"])] for row in playtimes]
        scaler = sklearn["StandardScaler"]()
        scaled = scaler.fit_transform(values)
        return scaled, scaler

    def _build_feature_matrix(self, playtimes: list[dict[str, float]], feature_keys: list[str], sklearn: dict[str, object]):
        values = [[float(row.get(key, 0.0)) for key in feature_keys] for row in playtimes]
        scaler = sklearn["StandardScaler"]()
        X = scaler.fit_transform(values)
        return X, scaler

    @staticmethod
    def _build_kmeans(kmeans_class, n_clusters: int):
        try:
            return kmeans_class(
                n_clusters=n_clusters,
                init=KMeansPlaytimeClusterer.INIT,
                n_init=KMeansPlaytimeClusterer.N_INIT,
                max_iter=KMeansPlaytimeClusterer.MAX_ITER,
                tol=KMeansPlaytimeClusterer.TOL,
                random_state=KMeansPlaytimeClusterer.RANDOM_STATE,
                algorithm=KMeansPlaytimeClusterer.ALGORITHM,
            )
        except TypeError:
            return kmeans_class(
                n_clusters=n_clusters,
                init=KMeansPlaytimeClusterer.INIT,
                n_init=10,
                max_iter=KMeansPlaytimeClusterer.MAX_ITER,
                tol=KMeansPlaytimeClusterer.TOL,
                random_state=KMeansPlaytimeClusterer.RANDOM_STATE,
                algorithm=KMeansPlaytimeClusterer.ALGORITHM,
            )
