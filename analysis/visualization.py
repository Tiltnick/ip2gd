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
        event_types = sorted({str(step["event_type"]) for session in sequences for step in session["sequence"]})
        room_index = {room: index for index, room in enumerate(rooms)}
        event_index = {event_type: index for index, event_type in enumerate(event_types)}
        event_divisor = max(len(event_types), 1)
        fig, ax = plt.subplots(figsize=(12, max(5, len(rooms) * 0.8)))
        palette = plt.get_cmap("tab20")
        for index, session in enumerate(sequences):
            xs = [int(step["order"]) for step in session["sequence"]]
            ys = [room_index[str(step["room"])] for step in session["sequence"]]
            colors = [
                palette(event_index[str(step["event_type"])] / event_divisor)
                for step in session["sequence"]
            ]
            ax.plot(xs, ys, linewidth=1, alpha=0.2, color="#666666")
            ax.scatter(xs, ys, c=colors, s=40, alpha=0.85, edgecolors="none")
        ax.set_yticks(range(len(rooms)))
        ax.set_yticklabels(rooms)
        ax.set_xlabel("Ereignis-Reihenfolge")
        ax.set_ylabel("Raum")
        ax.set_title("Playtrace nach Raum")
        ax.grid(True, alpha=0.2)
        legend_handles = [
            plt.Line2D(
                [0],
                [0],
                marker="o",
                color="w",
                label=event_type,
                markerfacecolor=palette(event_index[event_type] / event_divisor),
                markersize=6,
            )
            for event_type in event_types
        ]
        ax.legend(handles=legend_handles, title="Event-Typ", fontsize=8, loc="upper left", bbox_to_anchor=(1.02, 1))
        return self._save(fig, "playtrace_by_room.png")

    def plot_playtrace_timeline_by_session(self, sequences: list[dict[str, object]]) -> Path | None:
        if not self._available("Playtrace Timeline"):
            return None
        if not sequences:
            print("  playtrace_timeline_by_session.png übersprungen – keine Playtrace-Daten.")
            return None
        rooms = sorted({str(step["room"]) for session in sequences for step in session["sequence"]})
        room_index = {room: index for index, room in enumerate(rooms)}
        room_divisor = max(len(rooms), 1)
        fig, ax = plt.subplots(figsize=(12, max(5, len(sequences) * 0.8)))
        palette = plt.get_cmap("tab20")
        for session_index, session in enumerate(sequences):
            xs = [float(step["relative_t_msec"]) / 1000.0 for step in session["sequence"]]
            ys = [session_index] * len(xs)
            colors = [palette(room_index[str(step["room"])] / room_divisor) for step in session["sequence"]]
            ax.plot(xs, ys, linewidth=1, alpha=0.2, color="#666666")
            ax.scatter(xs, ys, c=colors, s=35, alpha=0.85, edgecolors="none")
        ax.set_xlabel("Zeit seit Session-Start (Sekunden)")
        ax.set_ylabel("Session")
        ax.set_yticks(range(len(sequences)))
        ax.set_yticklabels([str(session["session_id"])[:16] for session in sequences], fontsize=8)
        ax.set_title("Playtrace Timeline pro Session")
        ax.grid(True, alpha=0.2)
        return self._save(fig, "playtrace_timeline_by_session.png")

    def plot_playtrace_transition_graph(self, transitions: list[dict[str, object]]) -> Path | None:
        if not self._available("Transition-Graph"):
            return None
        if not transitions:
            print("  playtrace_transition_graph.png übersprungen – keine Transition-Daten.")
            return None
        try:
            import networkx as nx
        except ImportError:
            print("Hinweis: networkx ist nicht installiert. Transition-Graph wird übersprungen.")
            print("pip install networkx")
            return None

        graph = nx.DiGraph()
        for row in transitions:
            source = str(row["source_room"])
            target = str(row["target_room"])
            weight = int(row["count"])
            graph.add_edge(source, target, weight=weight)

        if graph.number_of_nodes() == 0:
            print("  playtrace_transition_graph.png übersprungen – Graph ist leer.")
            return None

        fig, ax = plt.subplots(figsize=(10, 8))
        positions = nx.spring_layout(graph, seed=42)
        edge_weights = [graph[u][v]["weight"] for u, v in graph.edges()]
        max_weight = max(edge_weights) if edge_weights else 1
        widths = [1 + (4 * weight / max_weight) for weight in edge_weights]
        nx.draw_networkx_nodes(graph, positions, node_color="#8ecae6", node_size=1700, ax=ax)
        nx.draw_networkx_labels(graph, positions, font_size=9, ax=ax)
        nx.draw_networkx_edges(
            graph,
            positions,
            width=widths,
            edge_color="#555555",
            arrows=True,
            arrowsize=18,
            connectionstyle="arc3,rad=0.05",
            ax=ax,
        )
        edge_labels = {(u, v): graph[u][v]["weight"] for u, v in graph.edges()}
        nx.draw_networkx_edge_labels(graph, positions, edge_labels=edge_labels, font_size=8, ax=ax)
        ax.set_title("Playtrace Transition-Graph (Räume)")
        ax.axis("off")
        return self._save(fig, "playtrace_transition_graph.png")

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
