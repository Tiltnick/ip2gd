"""Orchestrates telemetry analysis."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .event_analyzer import SemanticEventAnalyzer
from .exporter import TelemetryExporter
from .kmeans_playtime_clusterer import KMeansPlaytimeClusterer
from .playtrace_analyzer import PlaytraceAnalyzer
from .room_time_analyzer import RoomTimeAnalyzer
from .session_analyzer import SessionAnalyzer
from .telemetry_loader import TelemetryLoader
from .visualization import TelemetryVisualizer


class AnalysisPipeline:
    """Runs telemetry loading, analysis, export, and visualization."""

    def __init__(self) -> None:
        self.loader = TelemetryLoader()
        self.session_analyzer = SessionAnalyzer()
        self.room_time_analyzer = RoomTimeAnalyzer(self.session_analyzer)
        self.event_analyzer = SemanticEventAnalyzer()
        self.playtrace_analyzer = PlaytraceAnalyzer(self.session_analyzer, self.event_analyzer)
        self.clusterer = KMeansPlaytimeClusterer()

    def run(
        self,
        input_path: str | Path,
        output_dir: str | Path,
        *,
        include_clusters: bool = True,
        include_room_analysis: bool = True,
        include_semantic_analysis: bool = True,
        include_playtrace: bool = True,
    ) -> dict[str, Any]:
        exporter = TelemetryExporter(output_dir)
        visualizer = TelemetryVisualizer(exporter.output_dir)

        print("Lade Daten...")
        events = self.loader.load(input_path)
        report = self.loader.last_report
        print(
            f"  Dateien: {report.files_read}, Rohzeilen: {report.raw_rows}, "
            f"Events: {report.normalized_events}, übersprungen: {report.skipped_lines}\n"
        )

        session_durations = self.session_analyzer.compute_all_session_durations(events)
        print(f"  Gültige Sessions mit Zeitdaten: {len(session_durations)}")

        room_times: list[dict[str, Any]] = []
        room_times_path = None
        semantic_counts: list[dict[str, Any]] = []
        semantic_events_path = None
        playtrace_sequences: list[dict[str, Any]] = []

        if include_room_analysis:
            room_times = self.room_time_analyzer.compute_room_times_for_all_sessions(events)
            room_times_path = exporter.save_csv(
                "room_times.csv",
                room_times,
                ["session_id", "room", "time_msec", "time_seconds", "time_minutes"],
            ) if room_times else None
            visualizer.plot_room_times(room_times)

        if include_semantic_analysis:
            semantic_counts = self.event_analyzer.compute_events_per_room(events)
            semantic_events_path = exporter.save_csv(
                "semantic_events_per_room.csv",
                semantic_counts,
                ["room", "event_type", "count"],
            ) if semantic_counts else None
            visualizer.plot_semantic_events_per_room(semantic_counts)

        if include_playtrace:
            playtrace_sequences = self.playtrace_analyzer.build_sequences(events)
            visualizer.plot_playtrace_by_room(playtrace_sequences)

        cluster_rows = None
        cluster_summary: list[dict[str, Any]] = []
        elbow_data: list[dict[str, float]] = []
        if include_clusters:
            cluster_rows, elbow_data = self.clusterer.cluster_playtimes(session_durations)
            visualizer.plot_playtime_histogram(session_durations)
            visualizer.plot_playtime_elbow(elbow_data, final_k=3)
            if cluster_rows:
                cluster_summary = self.clusterer.build_cluster_summary(cluster_rows)
                exporter.save_csv(
                    "playtime_clusters.csv",
                    cluster_rows,
                    [
                        "session_id",
                        "playtime_msec",
                        "playtime_seconds",
                        "playtime_minutes",
                        "cluster_id",
                        "player_type",
                    ],
                )
                exporter.save_json(
                    "playtime_clusters.json",
                    {"sessions": cluster_rows, "cluster_summary": cluster_summary},
                )
                visualizer.plot_playtime_clusters(cluster_rows)

        return {
            "events": events,
            "session_durations": session_durations,
            "room_times": room_times,
            "room_times_path": room_times_path,
            "semantic_counts": semantic_counts,
            "semantic_events_path": semantic_events_path,
            "playtrace_sequences": playtrace_sequences,
            "cluster_rows": cluster_rows,
            "cluster_summary": cluster_summary,
            "elbow_data": elbow_data,
        }
