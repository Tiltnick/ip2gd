"""K-Means-Clustering auf dem mehrdimensionalen Feature-Vektor.

Umsetzung von Kapitel 3.4 / 5.2 / 5.3:
 * Z-Standardisierung der Merkmale (StandardScaler)
 * K-Means (scikit-learn) mit fixiertem random_state
 * Auswahl der Clusteranzahl über den mittleren Silhouetten-Koeffizienten
   nach Rousseeuw (ergänzt um die Elbow-/Inertia-Werte)

Die K-Means-Konfiguration ist bewusst identisch zu
KMeansPlaytimeClusterer, damit beide Analysen vergleichbar bleiben.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from statistics import mean

from .feature_builder import DEFAULT_CLUSTER_FEATURES

RANDOM_STATE = 42
INIT = "k-means++"
N_INIT = "auto"          # Fallback: 10 (siehe _make_kmeans)
MAX_ITER = 300
TOL = 1e-4
ALGORITHM = "lloyd"

# Untersuchter Wertebereich für k (Kapitel 5.3)
K_RANGE = list(range(2, 9))   # k = 2, 3, ..., 8


@dataclass(slots=True)
class ClusterResult:
    sessions: list[dict[str, float | int | str]] = field(default_factory=list)
    silhouette_table: list[dict[str, float]] = field(default_factory=list)  # k, silhouette, inertia
    chosen_k: int | None = None
    feature_keys: list[str] = field(default_factory=list)
    cluster_summary: list[dict[str, float | int | str]] = field(default_factory=list)


class KMeansFeatureClusterer:
    def __init__(self) -> None:
        self._sklearn: dict[str, object] | None = None

    # -- öffentlich -----------------------------------------------------
    def run(
        self,
        feature_rows: list[dict[str, float | str]],
        *,
        feature_keys: list[str] | None = None,
        k_range: list[int] | None = None,
        final_k: int | None = None,
    ) -> ClusterResult:
        keys = [k for k in (feature_keys or DEFAULT_CLUSTER_FEATURES) if feature_rows and k in feature_rows[0]]
        result = ClusterResult(feature_keys=keys)
        if len(feature_rows) < 3 or not keys:
            print("  Feature-Clustering übersprungen – zu wenige Sessions oder keine Merkmale.")
            return result

        sk = self._import_sklearn()
        if sk is None:
            print("  Feature-Clustering übersprungen – scikit-learn ist nicht installiert.")
            return result

        ks = [k for k in (k_range or K_RANGE) if 2 <= k < len(feature_rows)]
        X = self._scale(feature_rows, keys, sk)

        for k in ks:
            model = self._make_kmeans(sk["KMeans"], k)
            labels = model.fit_predict(X)
            sil = float(sk["silhouette_score"](X, labels)) if len(set(labels)) > 1 else float("nan")
            result.silhouette_table.append(
                {"k": float(k), "silhouette": round(sil, 4), "inertia": round(float(model.inertia_), 4)}
            )

        if final_k is None and result.silhouette_table:
            best = max(result.silhouette_table, key=lambda row: row["silhouette"])
            final_k = int(best["k"])
        result.chosen_k = final_k

        if final_k and 2 <= final_k < len(feature_rows):
            model = self._make_kmeans(sk["KMeans"], final_k)
            labels = model.fit_predict(X)
            # Cluster nach Größe stabil umnummerieren (0 = größtes)
            order = sorted(range(final_k), key=lambda c: -list(labels).count(c))
            remap = {old: new for new, old in enumerate(order)}
            for row, raw_label in zip(feature_rows, labels):
                enriched = dict(row)
                enriched["cluster_id"] = int(remap[int(raw_label)])
                result.sessions.append(enriched)
            result.cluster_summary = self._summary(result.sessions, keys)

        return result

    # -- Hilfen -------------------------------------------------------
    def _summary(self, sessions: list[dict], keys: list[str]) -> list[dict[str, float | int | str]]:
        out: list[dict[str, float | int | str]] = []
        cluster_ids = sorted({int(s["cluster_id"]) for s in sessions})
        for cid in cluster_ids:
            members = [s for s in sessions if int(s["cluster_id"]) == cid]
            entry: dict[str, float | int | str] = {"cluster_id": cid, "n_sessions": len(members)}
            for key in keys:
                vals = [float(m.get(key, 0.0)) for m in members]
                entry[f"mean_{key}"] = round(mean(vals), 4)
            out.append(entry)
        return out

    def _scale(self, rows: list[dict], keys: list[str], sk: dict[str, object]):
        matrix = [[float(r.get(k, 0.0)) for k in keys] for r in rows]
        scaler = sk["StandardScaler"]()
        return scaler.fit_transform(matrix)

    def _import_sklearn(self) -> dict[str, object] | None:
        if self._sklearn is not None:
            return self._sklearn
        try:
            from sklearn.cluster import KMeans
            from sklearn.metrics import silhouette_score
            from sklearn.preprocessing import StandardScaler
        except ImportError:
            self._sklearn = None
            return None
        self._sklearn = {
            "KMeans": KMeans,
            "silhouette_score": silhouette_score,
            "StandardScaler": StandardScaler,
        }
        return self._sklearn

    @staticmethod
    def _make_kmeans(kmeans_cls, n_clusters: int):
        try:
            return kmeans_cls(
                n_clusters=n_clusters, init=INIT, n_init=N_INIT,
                max_iter=MAX_ITER, tol=TOL, random_state=RANDOM_STATE, algorithm=ALGORITHM,
            )
        except TypeError:
            return kmeans_cls(
                n_clusters=n_clusters, init=INIT, n_init=10,
                max_iter=MAX_ITER, tol=TOL, random_state=RANDOM_STATE, algorithm=ALGORITHM,
            )
