"""Semantic event analysis."""

from __future__ import annotations

from collections import Counter, defaultdict

from .telemetry_models import TelemetryEvent


class SemanticEventAnalyzer:
    """Aggregates semantic telemetry events."""

    NON_SEMANTIC_EVENTS = {
        "movement_sample",
        "scene_changed",
        "semantic_snapshot",
        "session_started",
        "session_ended",
        "unknown",
    }

    def filter_semantic_events(self, events: list[TelemetryEvent]) -> list[TelemetryEvent]:
        return [event for event in events if event.event_type not in self.NON_SEMANTIC_EVENTS]

    def compute_events_per_room(self, events: list[TelemetryEvent]) -> list[dict[str, int | str]]:
        counter: Counter[tuple[str, str]] = Counter()
        for event in self.filter_semantic_events(events):
            room = event.room or "unknown"
            counter[(room, event.event_type)] += 1
        return [
            {"room": room, "event_type": event_type, "count": count}
            for (room, event_type), count in sorted(counter.items(), key=lambda item: (item[0][0], item[0][1]))
        ]

    def compute_events_per_session(self, events: list[TelemetryEvent]) -> dict[str, dict[str, int]]:
        grouped: dict[str, dict[str, int]] = defaultdict(lambda: defaultdict(int))
        for event in self.filter_semantic_events(events):
            if not event.session_id:
                continue
            grouped[event.session_id][event.event_type] += 1
        return {session_id: dict(counts) for session_id, counts in grouped.items()}
