"""Session-Zuschnitt: alle Sessions auf einen gemeinsamen Inhaltsabschnitt
begrenzen, damit die Session-Laenge das Clustering nicht dominiert.

Hintergrund (Kapitel 5.1): Die Testlaeufe sollen nur bis zu einem festen Punkt
im Spiel gehen (Raumschiff -> Aussenbereich 1 -> Wueste inkl. Sternbild-Raetsel).
Laeuft eine Session weiter, werden die Ereignisse ab dem ersten Betreten einer
"Stopp-Szene" verworfen. Optional zusaetzlich eine Zeitobergrenze.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass, field

from .area_types import resolve_scene, scene_name
from .telemetry_models import TelemetryEvent

# Szenen, die jenseits des gewuenschten Abschnitts liegen (Kleinschreibung,
# Teilstring-Vergleich gegen aufgeloesten Pfad + Kurznamen).
DEFAULT_STOP_SCENES: list[str] = [
    "outside_3",
    "outside_4",
    "temple",
    "sams_cave",
    "map_generation",
    "ending_scene",
]


@dataclass(slots=True)
class TruncationReport:
    n_sessions: int = 0
    n_truncated: int = 0
    stop_scenes: list[str] = field(default_factory=list)
    max_minutes: float | None = None
    details: list[dict] = field(default_factory=list)  # session_id, reason, kept_minutes


def _matches_stop(room: str | None, stop_scenes: list[str]) -> bool:
    if not room:
        return False
    resolved = resolve_scene(room).lower()
    short = scene_name(room).lower()
    return any(tok in resolved or tok in short for tok in stop_scenes)


def truncate_sessions(
    events: list[TelemetryEvent],
    *,
    stop_scenes: list[str] | None = None,
    max_minutes: float | None = None,
) -> tuple[list[TelemetryEvent], TruncationReport]:
    """Begrenzt jede Session auf den gemeinsamen Abschnitt.

    * ``stop_scenes`` -- Session endet beim ersten Ereignis in einer dieser
      Szenen (Default: Bereiche hinter der Wueste). Leere Liste = aus.
    * ``max_minutes`` -- zusaetzliche harte Zeitobergrenze je Session.
    """
    stops = DEFAULT_STOP_SCENES if stop_scenes is None else [s.strip().lower() for s in stop_scenes if s.strip()]
    report = TruncationReport(stop_scenes=list(stops), max_minutes=max_minutes)

    by_session: dict[str | None, list[TelemetryEvent]] = defaultdict(list)
    for e in events:
        by_session[e.session_id].append(e)

    out: list[TelemetryEvent] = []
    for sid, evs in by_session.items():
        if sid is None:
            out.extend(evs)
            continue
        report.n_sessions += 1
        evs = sorted(evs, key=lambda x: x.t_msec)
        start = evs[0].t_msec
        cutoff = start + max_minutes * 60000.0 if max_minutes else float("inf")
        reason = None
        if max_minutes and cutoff < evs[-1].t_msec:
            reason = f"max_minutes={max_minutes}"
        if stops:
            for e in evs:
                if e.t_msec > cutoff:
                    break
                room = e.room or (e.metadata or {}).get("to_room")
                if _matches_stop(room, stops):
                    cutoff = e.t_msec
                    reason = f"stop-scene {scene_name(room)}"
                    break
        kept = [e for e in evs if e.t_msec <= cutoff]
        out.extend(kept)
        if reason is not None:
            report.n_truncated += 1
            report.details.append(
                {
                    "session_id": sid,
                    "reason": reason,
                    "kept_minutes": round((kept[-1].t_msec - start) / 60000.0, 2),
                    "dropped_events": len(evs) - len(kept),
                }
            )
    out.sort(key=lambda x: (str(x.session_id), x.t_msec))
    return out, report
