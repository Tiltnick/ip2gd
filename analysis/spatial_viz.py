"""Räumliche Visualisierung: Heatmaps (numpy.histogram2d) und MDS-Projektion.

Umsetzung von Kapitel 5.4:
 * plot_movement_heatmaps  -> zweidimensionale Häufigkeitsverteilungen der
   Bewegungsdaten je Szene (Gesamtstichprobe)
 * plot_cluster_heatmaps   -> dieselben Heatmaps je Cluster
 * plot_feature_mds        -> MDS-Projektion der Session-Feature-Vektoren,
   eingefärbt nach Clusterzugehörigkeit
 * plot_silhouette         -> mittlerer Silhouetten-Koeffizient über k

Heatmaps werden je Szene erstellt, da Positionskoordinaten nur innerhalb
derselben Szene vergleichbar sind.
"""

from __future__ import annotations

from collections import defaultdict
from pathlib import Path

from .area_types import resolve_scene, scene_name
from .telemetry_models import TelemetryEvent

try:
    import numpy as np

    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False
    np = None

try:
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    plt = None

BINS = 60
MIN_SAMPLES_PER_SCENE = 30


def _movement_by_scene(
    events: list[TelemetryEvent],
) -> dict[str, list[tuple[float, float]]]:
    by_scene: dict[str, list[tuple[float, float]]] = defaultdict(list)
    for e in events:
        if e.event_type != "movement_sample":
            continue
        if e.position and "x" in e.position and "y" in e.position:
            x, y = float(e.position["x"]), float(e.position["y"])
        elif e.x is not None and e.y is not None:
            x, y = float(e.x), float(e.y)
        else:
            continue
        by_scene[resolve_scene(e.room) or "unknown"].append((x, y))
    return by_scene


class SpatialVisualizer:
    def __init__(self, output_dir: str | Path) -> None:
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    # -- Heatmaps ---------------------------------------------------------
    def plot_movement_heatmaps(self, events: list[TelemetryEvent], map_bounds: dict | None = None) -> list[Path]:
        if not self._ok("Heatmaps"):
            return []
        paths: list[Path] = []
        by_scene = _movement_by_scene(events)
        for scene, pts in sorted(by_scene.items(), key=lambda kv: -len(kv[1])):
            if len(pts) < MIN_SAMPLES_PER_SCENE:
                continue
            extent = self._extent(scene, pts, map_bounds)
            hist, xedges, yedges = self._hist2d(pts, extent)
            fig, ax = plt.subplots(figsize=(7, 6))
            im = ax.imshow(
                hist.T, origin="upper", aspect="equal",
                extent=(xedges[0], xedges[-1], yedges[-1], yedges[0]),
                cmap="magma",
            )
            ax.set_title(f"Bewegungs-Heatmap – {scene_name(scene)} (n={len(pts)})")
            ax.set_xlabel("x (Pixel)")
            ax.set_ylabel("y (Pixel)")
            fig.colorbar(im, ax=ax, label="Häufigkeit")
            paths.append(self._save(fig, f"heatmap_{scene_name(scene)}.png"))
        return paths

    def plot_cluster_heatmaps(
        self,
        events: list[TelemetryEvent],
        cluster_by_session: dict[str, int],
        map_bounds: dict | None = None,
    ) -> list[Path]:
        if not self._ok("Cluster-Heatmaps"):
            return []
        clusters = sorted(set(cluster_by_session.values()))
        # Szenen nach Gesamt-Sampleanzahl
        scene_counts: dict[str, int] = defaultdict(int)
        for e in events:
            if e.event_type == "movement_sample":
                scene_counts[resolve_scene(e.room) or "unknown"] += 1
        top_scenes = [s for s, c in sorted(scene_counts.items(), key=lambda kv: -kv[1]) if c >= MIN_SAMPLES_PER_SCENE]

        paths: list[Path] = []
        for scene in top_scenes:
            pts_all = [
                e for e in events
                if e.event_type == "movement_sample" and (resolve_scene(e.room) or "unknown") == scene
            ]
            extent = self._extent(scene, [self._xy(e) for e in pts_all if self._xy(e)], map_bounds)
            fig, axes = plt.subplots(1, len(clusters), figsize=(4.2 * len(clusters), 4.4), squeeze=False)
            for col, cid in enumerate(clusters):
                pts = [
                    self._xy(e) for e in pts_all
                    if cluster_by_session.get(str(e.session_id)) == cid and self._xy(e)
                ]
                ax = axes[0][col]
                if len(pts) >= 5:
                    hist, xe, ye = self._hist2d(pts, extent)
                    ax.imshow(
                        hist.T, origin="upper", aspect="equal",
                        extent=(xe[0], xe[-1], ye[-1], ye[0]), cmap="magma",
                    )
                else:
                    ax.text(0.5, 0.5, "zu wenige\nDaten", ha="center", va="center", transform=ax.transAxes)
                ax.set_title(f"Cluster {cid} (n={len(pts)})")
                ax.set_xticks([])
                ax.set_yticks([])
            fig.suptitle(f"Cluster-Heatmaps – {scene_name(scene)}")
            paths.append(self._save(fig, f"cluster_heatmaps_{scene_name(scene)}.png"))
        return paths

    # -- MDS ------------------------------------------------------------
    def plot_feature_mds(
        self,
        feature_rows: list[dict[str, float | str]],
        feature_keys: list[str],
        cluster_by_session: dict[str, int] | None = None,
    ) -> Path | None:
        if not self._ok("MDS-Projektion"):
            return None
        try:
            from sklearn.manifold import MDS
            from sklearn.preprocessing import StandardScaler
        except ImportError:
            print("  MDS übersprungen – scikit-learn ist nicht installiert.")
            return None
        keys = [k for k in feature_keys if feature_rows and k in feature_rows[0]]
        if len(feature_rows) < 3 or not keys:
            print("  MDS übersprungen – zu wenige Sessions.")
            return None

        matrix = np.array([[float(r.get(k, 0.0)) for k in keys] for r in feature_rows])
        matrix = StandardScaler().fit_transform(matrix)
        # init explizit setzen (in neueren scikit-learn-Versionen aendert sich
        # sonst der Default) und normalized_stress nur uebergeben, wenn bekannt.
        mds = None
        for kwargs in (
            {"init": "random", "normalized_stress": "auto"},
            {"normalized_stress": "auto"},
            {},
        ):
            try:
                mds = MDS(n_components=2, random_state=42, n_init=4, **kwargs)
                break
            except TypeError:
                continue
        coords = mds.fit_transform(matrix)

        fig, ax = plt.subplots(figsize=(8, 6))
        if cluster_by_session:
            cids = [cluster_by_session.get(str(r["session_id"]), -1) for r in feature_rows]
            uniq = sorted(set(cids))
            cmap = plt.get_cmap("tab10")
            for cid in uniq:
                idx = [i for i, c in enumerate(cids) if c == cid]
                ax.scatter(
                    coords[idx, 0], coords[idx, 1], s=70, alpha=0.85,
                    color=cmap(uniq.index(cid) % 10),
                    label=f"Cluster {cid}" if cid >= 0 else "ohne Cluster",
                )
            ax.legend(title="Clusterzugehörigkeit")
        else:
            ax.scatter(coords[:, 0], coords[:, 1], s=70, alpha=0.85, color="#4466aa")
        ax.set_title("MDS-Projektion der Session-Feature-Vektoren")
        ax.set_xlabel("MDS-Dimension 1")
        ax.set_ylabel("MDS-Dimension 2")
        ax.grid(True, alpha=0.3)
        return self._save(fig, "feature_mds.png")

    # -- Silhouette ----------------------------------------------------
    def plot_silhouette(self, silhouette_table: list[dict[str, float]], chosen_k: int | None = None) -> Path | None:
        if not self._ok("Silhouetten-Plot") or not silhouette_table:
            return None
        ks = [int(r["k"]) for r in silhouette_table]
        sil = [float(r["silhouette"]) for r in silhouette_table]
        fig, ax = plt.subplots(figsize=(8, 5))
        ax.plot(ks, sil, marker="o", color="#4466aa", linewidth=2)
        if chosen_k in ks:
            ax.axvline(chosen_k, color="red", linestyle="--", alpha=0.7, label=f"gewähltes k={chosen_k}")
            ax.legend()
        ax.set_xlabel("Anzahl Cluster k")
        ax.set_ylabel("mittlerer Silhouetten-Koeffizient")
        ax.set_title("Silhouetten-Analyse")
        ax.set_xticks(ks)
        ax.grid(True, alpha=0.3)
        return self._save(fig, "silhouette_scores.png")

    # -- intern ------------------------------------------------------
    @staticmethod
    def _xy(e: TelemetryEvent) -> tuple[float, float] | None:
        if e.position and "x" in e.position and "y" in e.position:
            return float(e.position["x"]), float(e.position["y"])
        if e.x is not None and e.y is not None:
            return float(e.x), float(e.y)
        return None

    def _extent(self, scene: str, pts: list[tuple[float, float]], map_bounds: dict | None):
        if map_bounds:
            for key, val in map_bounds.items():
                if scene_name(key) == scene_name(scene):
                    return (
                        float(val["limit_left"]), float(val["limit_right"]),
                        float(val["limit_top"]), float(val["limit_bottom"]),
                    )
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        pad_x = (max(xs) - min(xs)) * 0.03 + 1.0
        pad_y = (max(ys) - min(ys)) * 0.03 + 1.0
        return (min(xs) - pad_x, max(xs) + pad_x, min(ys) - pad_y, max(ys) + pad_y)

    def _hist2d(self, pts: list[tuple[float, float]], extent):
        xs = np.array([p[0] for p in pts])
        ys = np.array([p[1] for p in pts])
        x0, x1, y0, y1 = extent
        hist, xedges, yedges = np.histogram2d(
            xs, ys, bins=BINS, range=[[x0, x1], [min(y0, y1), max(y0, y1)]]
        )
        return hist, xedges, yedges

    def _ok(self, label: str) -> bool:
        if HAS_NUMPY and HAS_MPL:
            return True
        print(f"  {label} übersprungen – numpy/matplotlib fehlt.")
        return False

    def _save(self, fig, filename: str) -> Path:
        path = self.output_dir / filename
        fig.tight_layout()
        fig.savefig(path, dpi=150, bbox_inches="tight")
        plt.close(fig)
        print(f"  Plot gespeichert: {path}")
        return path
