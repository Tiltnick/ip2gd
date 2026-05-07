"""Centralized visualization helpers."""

from __future__ import annotations

from collections import defaultdict
from pathlib import Path

try:
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    plt = None


class TelemetryVisualizer:
    """Creates non-interactive matplotlib figures."""

    def __init__(self, output_dir: str | Path) -> None:
        self.output_dir = Path(output_dir)

    def plot_playtime_elbow(self, elbow_data: list[dict[str, float]], final_k: int = 3) -> Path | None:
        if not self._available("Elbow-Methode"):
            return None
        if not elbow_data:
            print("  Elbow-Methode übersprungen – keine Daten.")
            return None
        ks = [int(item["k"]) for item in elbow_data]
        inertias = [item["inertia"] for item in elbow_data]
        fig, ax = plt.subplots(figsize=(8, 5))
        ax.plot(ks, inertias, marker="o", color="#4466aa", linewidth=2)
        if final_k in ks:
            index = ks.index(final_k)
            ax.axvline(final_k, color="red", linestyle="--", alpha=0.7, label=f"Final k={final_k}")
            ax.scatter([final_k], [inertias[index]], color="red", zorder=5)
        ax.set_xlabel("Anzahl Cluster k")
        ax.set_ylabel("Inertia / WCSS")
        ax.set_title("Elbow Method – Spielzeit-Clustering")
        ax.set_xticks(ks)
        ax.grid(True, alpha=0.3)
        ax.legend()
        return self._save(fig, "playtime_elbow_method.png")

    def plot_playtime_clusters(self, enriched: list[dict[str, float | int | str]]) -> Path | None:
        if not self._available("Spielzeit-Cluster"):
            return None
        if not enriched:
            print("  Cluster-Plot übersprungen – keine Clusterdaten.")
            return None
        sorted_rows = sorted(enriched, key=lambda row: float(row["playtime_minutes"]))
        colors = {
            "schnelle Spieler": "#2ecc71",
            "Standard-Spieler": "#3498db",
            "langsame Spieler": "#e74c3c",
        }
        fig, ax = plt.subplots(figsize=(10, 6))
        used_labels: set[str] = set()
        for index, row in enumerate(sorted_rows):
            label = str(row["player_type"])
            ax.scatter(
                index,
                float(row["playtime_minutes"]),
                color=colors.get(label, "#666666"),
                s=60,
                alpha=0.85,
                label=None if label in used_labels else label,
            )
            used_labels.add(label)
        ax.set_xlabel("Session-Index (nach Spielzeit sortiert)")
        ax.set_ylabel("Spielzeit in Minuten")
        ax.set_title("K-Means Spielzeit-Clustering")
        ax.grid(True, alpha=0.3)
        ax.legend(title="Spielertyp")
        return self._save(fig, "playtime_kmeans_clusters.png")

    def plot_playtime_histogram(self, playtimes: list[dict[str, float]]) -> Path | None:
        if not self._available("Spielzeit-Histogramm"):
            return None
        if not playtimes:
            print("  Histogramm übersprungen – keine Spielzeitdaten.")
            return None
        minutes = [row["playtime_minutes"] for row in playtimes]
        fig, ax = plt.subplots(figsize=(8, 5))
        ax.hist(minutes, bins=min(max(len(minutes), 3), 10), color="#6c5ce7", alpha=0.85, edgecolor="white")
        ax.set_xlabel("Spielzeit in Minuten")
        ax.set_ylabel("Anzahl Sessions")
        ax.set_title("Histogramm der Spielzeiten")
        ax.grid(axis="y", alpha=0.3)
        return self._save(fig, "playtime_histogram.png")

    def plot_room_times(self, room_times: list[dict[str, float | str]]) -> Path | None:
        if not self._available("Zeit pro Raum"):
            return None
        if not room_times:
            print("  room_times.png übersprungen – keine Raumzeiten.")
            return None
        totals: dict[str, float] = defaultdict(float)
        for row in room_times:
            totals[str(row["room"])] += float(row["time_minutes"])
        rooms = sorted(totals)
        values = [totals[room] for room in rooms]
        fig, ax = plt.subplots(figsize=(max(8, len(rooms) * 1.2), 5))
        ax.bar(rooms, values, color="#f39c12", alpha=0.9)
        ax.set_ylabel("Zeit in Minuten")
        ax.set_title("Zeit pro Raum")
        ax.grid(axis="y", alpha=0.3)
        ax.tick_params(axis="x", rotation=30)
        return self._save(fig, "room_times.png")

    def plot_semantic_events_per_room(self, room_event_counts: list[dict[str, int | str]]) -> Path | None:
        if not self._available("Semantische Events pro Raum"):
            return None
        if not room_event_counts:
            print("  semantic_events_per_room.png übersprungen – keine semantischen Events.")
            return None
        rooms = sorted({str(row["room"]) for row in room_event_counts})
        event_types = sorted({str(row["event_type"]) for row in room_event_counts})
        values = {(str(row["room"]), str(row["event_type"])): int(row["count"]) for row in room_event_counts}
        fig, ax = plt.subplots(figsize=(max(10, len(rooms) * 1.4), 6))
        bottoms = [0] * len(rooms)
        palette = plt.get_cmap("tab20")
        for index, event_type in enumerate(event_types):
            series = [values.get((room, event_type), 0) for room in rooms]
            ax.bar(rooms, series, bottom=bottoms, label=event_type, color=palette(index / max(len(event_types), 1)))
            bottoms = [bottom + value for bottom, value in zip(bottoms, series)]
        ax.set_ylabel("Anzahl Events")
        ax.set_title("Semantische Events pro Raum")
        ax.tick_params(axis="x", rotation=30)
        ax.grid(axis="y", alpha=0.3)
        ax.legend(fontsize=8)
        return self._save(fig, "semantic_events_per_room.png")

    def plot_playtrace_by_room(self, sequences: list[dict[str, object]]) -> Path | None:
        if not self._available("Playtrace"):
            return None
        if not sequences:
            print("  playtrace_by_room.png übersprungen – keine Playtrace-Daten.")
            return None
        rooms = sorted({str(step["room"]) for session in sequences for step in session["sequence"]})
        room_index = {room: index for index, room in enumerate(rooms)}
        fig, ax = plt.subplots(figsize=(12, max(4, len(sequences) * 1.2)))
        palette = plt.get_cmap("tab10")
        for index, session in enumerate(sequences):
            session_id = str(session["session_id"])
            xs = [int(step["order"]) for step in session["sequence"]]
            ys = [room_index[str(step["room"])] for step in session["sequence"]]
            ax.plot(xs, ys, marker="o", linewidth=1.5, alpha=0.8, label=session_id[:12], color=palette(index % 10))
        ax.set_yticks(range(len(rooms)))
        ax.set_yticklabels(rooms)
        ax.set_xlabel("Ereignis-Reihenfolge")
        ax.set_ylabel("Raum")
        ax.set_title("Playtrace nach Raum")
        ax.grid(True, alpha=0.2)
        ax.legend(fontsize=7, loc="upper left", bbox_to_anchor=(1.02, 1))
        return self._save(fig, "playtrace_by_room.png")

    def _available(self, label: str) -> bool:
        if HAS_MATPLOTLIB:
            return True
        print(f"  {label} übersprungen – matplotlib ist nicht installiert.")
        return False

    def _save(self, fig, filename: str) -> Path:
        path = self.output_dir / filename
        fig.tight_layout()
        fig.savefig(path, dpi=150, bbox_inches="tight")
        plt.close(fig)
        print(f"  Plot gespeichert: {path}")
        return path
