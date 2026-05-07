"""Room-based telemetry analysis."""

from __future__ import annotations

from collections import defaultdict

from .session_analyzer import SessionAnalyzer
from .telemetry_models import TelemetryEvent


class RoomTimeAnalyzer:
    """Computes time spent per room."""

    def __init__(self, session_analyzer: SessionAnalyzer | None = None) -> None:
        self.session_analyzer = session_analyzer or SessionAnalyzer()

    def compute_room_times_for_session(self, session_events: list[TelemetryEvent]) -> list[dict[str, float | str]]:
        if len(session_events) < 2:
            return []
        sorted_events = sorted(session_events, key=lambda item: item.t_msec)
        room_times: dict[str, float] = defaultdict(float)
        for current, next_event in zip(sorted_events, sorted_events[1:]):
            if not current.room:
                continue
            delta = next_event.t_msec - current.t_msec
            if delta <= 0:
                continue
            room_times[current.room] += delta
        session_id = sorted_events[0].session_id
        return [
            {
                "session_id": session_id,
                "room": room,
                "time_msec": time_msec,
                "time_seconds": time_msec / 1000.0,
                "time_minutes": time_msec / 60000.0,
            }
            for room, time_msec in sorted(room_times.items(), key=lambda item: item[0])
            if time_msec > 0
        ]

    def compute_room_times_for_all_sessions(self, events: list[TelemetryEvent]) -> list[dict[str, float | str]]:
        grouped = self.session_analyzer.group_by_session(events)
        records: list[dict[str, float | str]] = []
        for session_events in grouped.values():
            records.extend(self.compute_room_times_for_session(session_events))
        return records
