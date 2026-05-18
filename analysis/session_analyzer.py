from __future__ import annotations

from collections import defaultdict

from .telemetry_models import TelemetryEvent


class SessionAnalyzer:
    """Groups events by session and computes playtime metrics."""

    def group_by_session(self, events: list[TelemetryEvent]) -> dict[str, list[TelemetryEvent]]:
        grouped: dict[str, list[TelemetryEvent]] = defaultdict(list)
        for event in events:
            if not event.session_id:
                continue
            grouped[event.session_id].append(event)
        for session_events in grouped.values():
            session_events.sort(key=lambda item: item.t_msec)
        return dict(grouped)

    def compute_session_duration(self, session_events: list[TelemetryEvent]) -> dict[str, float] | None:
        if not session_events:
            return None
        valid_times = [event.t_msec for event in session_events]
        if len(valid_times) < 2:
            return None
        start_time = min(valid_times)
        end_time = max(valid_times)
        duration_msec = end_time - start_time
        if duration_msec <= 0:
            return None
        session_id = session_events[0].session_id
        return {
            "session_id": session_id,
            "start_msec": start_time,
            "end_msec": end_time,
            "playtime_msec": duration_msec,
            "playtime_seconds": duration_msec / 1000.0,
            "playtime_minutes": duration_msec / 60000.0,
            "event_count": float(len(session_events)),
        }

    def compute_all_session_durations(self, events: list[TelemetryEvent]) -> list[dict[str, float]]:
        grouped = self.group_by_session(events)
        durations: list[dict[str, float]] = []
        for session_id, session_events in sorted(grouped.items()):
            duration = self.compute_session_duration(session_events)
            if duration:
                durations.append(duration)
            else:
                print(f"  Session übersprungen (ungültige Zeitwerte): {session_id}")
        return durations
