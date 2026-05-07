"""Playtrace preparation based on semantic events."""

from __future__ import annotations

from collections import defaultdict

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
            sequence = []
            for index, event in enumerate(session_events):
                sequence.append(
                    {
                        "order": index,
                        "session_id": session_id,
                        "event_type": event.event_type,
                        "room": event.room or "unknown",
                        "t_msec": event.t_msec,
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
