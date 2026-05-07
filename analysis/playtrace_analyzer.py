"""Playtrace preparation based on semantic events."""

from __future__ import annotations

from collections import Counter, defaultdict

from .event_analyzer import SemanticEventAnalyzer
from .session_analyzer import SessionAnalyzer
from .telemetry_models import TelemetryEvent


class PlaytraceAnalyzer:
    """Builds lightweight playtrace-ready sequences."""

    def __init__(
        self,
        session_analyzer: SessionAnalyzer | None = None,
        event_analyzer: SemanticEventAnalyzer | None = None,
    ) -> None:
        self.session_analyzer = session_analyzer or SessionAnalyzer()
        self.event_analyzer = event_analyzer or SemanticEventAnalyzer()

    def build_sequences(self, events: list[TelemetryEvent]) -> list[dict[str, object]]:
        grouped = self.session_analyzer.group_by_session(self.event_analyzer.filter_semantic_events(events))
        sequences: list[dict[str, object]] = []
        for session_id, session_events in sorted(grouped.items()):
            if not session_events:
                continue
            session_start = session_events[0].t_msec
            sequence = []
            for index, event in enumerate(session_events):
                sequence.append(
                    {
                        "order": index,
                        "session_id": session_id,
                        "event_type": event.event_type,
                        "room": event.room or "unknown",
                        "t_msec": event.t_msec,
                        "relative_t_msec": event.t_msec - session_start,
                    }
                )
            if sequence:
                sequences.append({"session_id": session_id, "sequence": sequence})
        return sequences

    def aggregate_by_room(self, sequences: list[dict[str, object]]) -> list[dict[str, object]]:
        room_events: dict[str, list[dict[str, object]]] = defaultdict(list)
        for session in sequences:
            for step in session["sequence"]:
                room_events[str(step["room"])].append(step)
        return [
            {"room": room, "events": sorted(steps, key=lambda step: (step["session_id"], step["order"]))}
            for room, steps in sorted(room_events.items(), key=lambda item: item[0])
        ]

    def flatten_sequences(self, sequences: list[dict[str, object]]) -> list[dict[str, object]]:
        rows: list[dict[str, object]] = []
        for session in sequences:
            session_id = str(session["session_id"])
            for step in session["sequence"]:
                rows.append(
                    {
                        "session_id": session_id,
                        "order": int(step["order"]),
                        "event_type": str(step["event_type"]),
                        "room": str(step["room"]),
                        "t_msec": float(step["t_msec"]),
                        "relative_t_msec": float(step["relative_t_msec"]),
                    }
                )
        return rows

    def compute_room_transitions(self, sequences: list[dict[str, object]]) -> list[dict[str, object]]:
        counter: Counter[tuple[str, str]] = Counter()
        for session in sequences:
            ordered_steps = sorted(session["sequence"], key=lambda step: int(step["order"]))
            ordered_rooms = [str(step["room"]) for step in ordered_steps]
            for source, target in zip(ordered_rooms, ordered_rooms[1:]):
                if source == target:
                    continue
                counter[(source, target)] += 1
        return [
            {"source_room": source, "target_room": target, "count": count}
            for (source, target), count in sorted(counter.items(), key=lambda item: (item[0][0], item[0][1]))
        ]
