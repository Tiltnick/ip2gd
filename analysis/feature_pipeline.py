"""Feature-basierte Analysepipeline (Kapitel 5.2 - 5.4).

Ablauf:  Laden  ->  Feature-Vektoren  ->  Standardisierung + K-Means
         ->  Silhouetten-Auswahl von k  ->  Export (CSV/JSON) + Visualisierung
         (Heatmaps, Cluster-Heatmaps, MDS, Silhouetten-Plot).

Ergaenzt AnalysisPipeline; nutzt dieselben Loader-/Exporter-Bausteine.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .exporter import TelemetryExporter
from .feature_builder import DEFAULT_CLUSTER_FEATURES, FEATURE_META, SessionFeatureBuilder
from .feature_clusterer import KMeansFeatureClusterer
from .session_analyzer import SessionAnalyzer
from .session_window import truncate_sessions
from .spatial_viz import SpatialVisualizer
from .telemetry_loader import TelemetryLoader


class FeatureAnalysisPipeline:
    def __init__(self) -> None:
        self.loader = TelemetryLoader()
        self.session_analyzer = SessionAnalyzer()
        self.feature_builder = SessionFeatureBuilder(self.session_analyzer)
        self.clusterer = KMeansFeatureClusterer()

    def run(
        self,
        input_path: str | Path,
        output_dir: str | Path,
        *,
        feature_keys: list[str] | None = None,
        final_k: int | None = None,
        stop_scenes: list[str] | None = None,
        max_minutes: float | None = None,
    ) -> dict[str, Any]:
        exporter = TelemetryExporter(output_dir)
        viz = SpatialVisualizer(exporter.output_dir)
        feature_keys = feature_keys or DEFAULT_CLUSTER_FEATURES

        print("Lade Daten ...")
        events = self.loader.load(input_path)
        report = self.loader.last_report

        # -- Sessions auf gemeinsamen Abschnitt zuschneiden (Kapitel 5.1) --
        events, trunc = truncate_sessions(
            events, stop_scenes=stop_scenes, max_minutes=max_minutes
        )
        if trunc.n_truncated:
            print(
                f"  Zuschnitt: {trunc.n_truncated}/{trunc.n_sessions} Sessions gekuerzt "
                f"(Stopp-Szenen: {', '.join(trunc.stop_scenes) or '-'}"
                + (f", max {trunc.max_minutes} min" if trunc.max_minutes else "")
                + ")"
            )
            for d in trunc.details:
                print(f"    {d['session_id']}: {d['reason']}, {d['kept_minutes']} min behalten")
        n_movement = sum(1 for e in events if e.event_type == "movement_sample")
        n_discrete = len(events) - n_movement
        print(
            f"  Dateien: {report.files_read}, Rohzeilen: {report.raw_rows}, "
            f"Events: {report.normalized_events} (Bewegung: {n_movement}, Ereignis: {n_discrete}), "
            f"uebersprungen: {report.skipped_lines}\n"
        )

        # -- Feature-Katalog exportieren (Tabelle fuer Kapitel 5.2) --------
        catalog_rows = [
            {"feature": name, "ebene": meta[0], "einheit": meta[1], "berechnung": meta[2]}
            for name, meta in FEATURE_META.items()
        ]
        exporter.save_csv("feature_catalog.csv", catalog_rows, ["feature", "ebene", "einheit", "berechnung"])

        # -- Feature-Vektoren --------------------------------------------
        feature_rows = self.feature_builder.build(events)
        print(f"  Feature-Vektoren: {len(feature_rows)} Sessions x {len(feature_keys)} Merkmale (Cluster-Vektor)")
        if feature_rows:
            all_cols = ["session_id"] + list(FEATURE_META.keys())
            exporter.save_csv("session_features.csv", feature_rows, all_cols)

        # -- Clustering + Silhouette ----------------------------------
        cluster = self.clusterer.run(
            feature_rows, feature_keys=feature_keys, final_k=final_k
        )
        if cluster.silhouette_table:
            exporter.save_csv("silhouette_scores.csv", cluster.silhouette_table, ["k", "silhouette", "inertia"])
        cluster_by_session: dict[str, int] = {}
        if cluster.sessions:
            cluster_by_session = {str(s["session_id"]): int(s["cluster_id"]) for s in cluster.sessions}
            exporter.save_csv(
                "session_clusters.csv",
                cluster.sessions,
                ["session_id", "cluster_id"] + list(FEATURE_META.keys()),
            )
            exporter.save_json(
                "clusters.json",
                {
                    "chosen_k": cluster.chosen_k,
                    "feature_keys": cluster.feature_keys,
                    "silhouette_table": cluster.silhouette_table,
                    "cluster_summary": cluster.cluster_summary,
                    "sessions": [
                        {"session_id": s["session_id"], "cluster_id": s["cluster_id"]}
                        for s in cluster.sessions
                    ],
                },
            )

        # -- Visualisierung ------------------------------------------
        map_bounds = self._load_map_bounds(input_path)
        viz.plot_silhouette(cluster.silhouette_table, cluster.chosen_k)
        viz.plot_movement_heatmaps(events, map_bounds)
        if cluster_by_session:
            viz.plot_cluster_heatmaps(events, cluster_by_session, map_bounds)
        viz.plot_feature_mds(feature_rows, feature_keys, cluster_by_session or None)

        # -- Kennzahlen fuer Kapitel 5.1 / 5.3 -------------------------
        playtimes = [float(r["playtime_min"]) for r in feature_rows] or [0.0]
        cluster_sizes: dict[int, int] = {}
        for s in cluster.sessions:
            cluster_sizes[int(s["cluster_id"])] = cluster_sizes.get(int(s["cluster_id"]), 0) + 1

        filter_stats = self._collect_filter_stats(events)

        study_summary = {
            "n_sessions": len(feature_rows),
            "n_events_total": len(events),
            "n_movement_events": n_movement,
            "n_discrete_events": n_discrete,
            "raw_rows": report.raw_rows,
            "skipped_lines": report.skipped_lines,
            "truncation": {
                "stop_scenes": trunc.stop_scenes,
                "max_minutes": trunc.max_minutes,
                "n_sessions": trunc.n_sessions,
                "n_truncated": trunc.n_truncated,
                "details": trunc.details,
            },
            "movement_filter": filter_stats,
            "playtime_minutes": {
                "min": round(min(playtimes), 2),
                "mean": round(sum(playtimes) / len(playtimes), 2),
                "max": round(max(playtimes), 2),
            },
            "n_features_total": len(FEATURE_META),
            "n_features_cluster_vector": len(cluster.feature_keys) or len(feature_keys),
            "cluster_feature_keys": cluster.feature_keys or feature_keys,
            "k_range": [int(r["k"]) for r in cluster.silhouette_table],
            "silhouette_table": cluster.silhouette_table,
            "chosen_k": cluster.chosen_k,
            "cluster_sizes": {str(k): v for k, v in sorted(cluster_sizes.items())},
        }
        exporter.save_json("study_summary.json", study_summary)
        print("\nFertig. Kennzahlen -> study_summary.json")
        return {
            "events": events,
            "feature_rows": feature_rows,
            "cluster": cluster,
            "study_summary": study_summary,
        }

    @staticmethod
    def _collect_filter_stats(events: list) -> dict[str, float] | None:
        """Bewegungs-Filterstatistik aus den 'movement_filter_stats'-Ereignissen
        aggregieren (wird von AnalyticsLogger je Session am Sessionende
        geschrieben). Liefert die Reduktion in Prozent fuer Kapitel 5.1."""
        considered = 0.0
        written = 0.0
        dropped_still = 0.0
        dropped_near = 0.0
        found = False
        for e in events:
            if e.event_type != "movement_filter_stats":
                continue
            found = True
            md = e.metadata or {}
            considered += float(md.get("considered", 0) or 0)
            written += float(md.get("written", 0) or 0)
            dropped_still += float(md.get("dropped_still", 0) or 0)
            dropped_near += float(md.get("dropped_near", 0) or 0)
        if not found or considered <= 0:
            return None
        return {
            "samples_considered": int(considered),
            "samples_written": int(written),
            "dropped_velocity_near_zero": int(dropped_still),
            "dropped_below_min_distance": int(dropped_near),
            "reduction_pct": round(100.0 * (considered - written) / considered, 2),
        }

    @staticmethod
    def _load_map_bounds(input_path: str | Path) -> dict | None:
        p = Path(input_path)
        candidates = [
            p / "map_bounds.json" if p.is_dir() else p.parent / "map_bounds.json",
            p.parent / "map_bounds.json",
        ]
        for c in candidates:
            if c.is_file():
                try:
                    return json.loads(c.read_text(encoding="utf-8"))
                except (json.JSONDecodeError, OSError):
                    return None
        return None
