"""K-Means clustering for playtime analysis."""

from __future__ import annotations

from statistics import mean


class KMeansPlaytimeClusterer:
    """Clusters sessions into fast, standard, and slow player groups."""

    PLAYER_TYPES = ["schnelle Spieler", "Standard-Spieler", "langsame Spieler"]

    def __init__(self) -> None:
        self._sklearn = None

    def cluster_playtimes(
        self,
        playtimes: list[dict[str, float]],
        final_k: int = 3,
        max_k: int = 10,
    ) -> tuple[list[dict[str, float | int | str]] | None, list[dict[str, float]]]:
        valid = [row for row in playtimes if row.get("playtime_minutes", 0) > 0]
        if not valid:
            print("  Keine gültigen Zeitwerte gefunden – K-Means wird übersprungen.")
            return None, []

        sklearn = self._import_sklearn()
        if sklearn is None:
            return None, []

        if len(valid) < final_k:
            print(f"  Zu wenige Sessions für K-Means mit {final_k} Clustern. Mindestens {final_k} Sessions erforderlich.")
            return None, self.compute_elbow(valid, min(max_k, len(valid)), sklearn)

        elbow_data = self.compute_elbow(valid, min(max_k, len(valid)), sklearn)

        scaler = sklearn["StandardScaler"]()
        values = [[row["playtime_minutes"]] for row in valid]
        scaled = scaler.fit_transform(values)
        model = sklearn["KMeans"](n_clusters=final_k, random_state=42, n_init=self._n_init_value())
        model.fit(scaled)

        centroids = scaler.inverse_transform(model.cluster_centers_)
        sorted_cluster_ids = sorted(range(len(centroids)), key=lambda idx: centroids[idx][0])
        cluster_rank = {cluster_id: rank for rank, cluster_id in enumerate(sorted_cluster_ids)}

        enriched: list[dict[str, float | int | str]] = []
        for index, row in enumerate(valid):
            raw_cluster = int(model.labels_[index])
            rank = cluster_rank[raw_cluster]
            enriched.append(
                {
                    **row,
                    "cluster_id": rank,
                    "player_type": self.PLAYER_TYPES[rank],
                }
            )
        return enriched, elbow_data

    def compute_elbow(
        self,
        playtimes: list[dict[str, float]],
        max_k: int,
        sklearn: dict[str, object] | None = None,
    ) -> list[dict[str, float]]:
        sklearn = sklearn or self._import_sklearn()
        if sklearn is None or not playtimes:
            return []
        values = [[row["playtime_minutes"]] for row in playtimes]
        scaled = sklearn["StandardScaler"]().fit_transform(values)
        elbow_data: list[dict[str, float]] = []
        for k in range(1, max_k + 1):
            model = sklearn["KMeans"](n_clusters=k, random_state=42, n_init=self._n_init_value())
            model.fit(scaled)
            elbow_data.append({"k": float(k), "inertia": float(model.inertia_)})
        return elbow_data

    def build_cluster_summary(self, enriched: list[dict[str, float | int | str]]) -> list[dict[str, float | int | str]]:
        summary: list[dict[str, float | int | str]] = []
        for cluster_id, player_type in enumerate(self.PLAYER_TYPES):
            values = [float(row["playtime_minutes"]) for row in enriched if int(row["cluster_id"]) == cluster_id]
            if not values:
                continue
            summary.append(
                {
                    "player_type": player_type,
                    "cluster_id": cluster_id,
                    "count": len(values),
                    "min_playtime_minutes": round(min(values), 4),
                    "max_playtime_minutes": round(max(values), 4),
                    "avg_playtime_minutes": round(mean(values), 4),
                }
            )
        return summary

    def _import_sklearn(self) -> dict[str, object] | None:
        if self._sklearn is not None:
            return self._sklearn
        try:
            from sklearn.cluster import KMeans
            from sklearn.preprocessing import StandardScaler
        except ImportError:
            print("Hinweis: scikit-learn ist nicht installiert. K-Means-Clustering wird übersprungen.")
            print("pip install scikit-learn")
            self._sklearn = None
            return None
        self._sklearn = {"KMeans": KMeans, "StandardScaler": StandardScaler}
        return self._sklearn

    @staticmethod
    def _n_init_value() -> str | int:
        return "auto"
