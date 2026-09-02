"""Generalisierung: aus Rohereignissen je Session einen Feature-Vektor bilden.

Setzt die in Kapitel 3.2 beschriebenen vier Generalisierungsebenen um
(räumlich, zeitlich, interaktionsbezogen, verhaltensbezogen) und erzeugt für
jede Spielsession einen einheitlichen, flachen Merkmalssatz.

Eingang:  list[TelemetryEvent]  (aus analysis.telemetry_loader.TelemetryLoader)
Ausgang:  list[dict]            (ein dict pro Session; Schlüssel s. FEATURE_META)
"""

from __future__ import annotations

import math
from collections import defaultdict
from dataclasses import dataclass

from .area_types import AUSSEN, area_type_for
from .session_analyzer import SessionAnalyzer
from .telemetry_models import TelemetryEvent

# ---------------------------------------------------------------------------
# Feature-Katalog:  name -> (Ebene, Einheit, Kurzbeschreibung / Berechnung)
# Diese Tabelle ist die Quelle für die Feature-Übersicht in Kapitel 5.2.
# ---------------------------------------------------------------------------
FEATURE_META: dict[str, tuple[str, str, str]] = {
    # -- räumlich -----------------------------------------------------------
    "distinct_areas":        ("räumlich", "Anzahl", "Zahl unterschiedlicher besuchter Szenen"),
    "distinct_area_types":   ("räumlich", "Anzahl", "Zahl unterschiedlicher Bereichstypen (innen/außen/rätsel/narrativ)"),
    "path_length_px":        ("räumlich", "Pixel", "Summe der Distanzen aufeinanderfolgender Bewegungsproben (je Szene)"),
    "mean_step_px":          ("räumlich", "Pixel", "path_length_px / Anzahl Bewegungsproben"),
    "revisit_ratio":         ("räumlich", "Anteil", "erneute Bereichsbetretungen / alle Bereichsbetretungen"),
    "backtracking_ratio":    ("räumlich", "Anteil", "Szenenwechsel zu bereits besuchtem Bereich / alle Szenenwechsel"),
    # -- zeitlich ---------------------------------------------------------
    "playtime_min":          ("zeitlich", "Minuten", "max(t_msec) - min(t_msec) der Session"),
    "move_time_min":         ("zeitlich", "Minuten", "Zeitanteil im Zustand move/run (aus Proben-Deltas)"),
    "idle_time_min":         ("zeitlich", "Minuten", "Zeitanteil ohne Bewegung"),
    "explore_time_ratio":    ("zeitlich", "Anteil", "Aufenthaltszeit in Außen-/Erkundungsbereichen / Gesamtzeit"),
    "time_to_first_quest_min": ("zeitlich", "Minuten", "Zeit von Session-Start bis erstem quest_completed"),
    "mean_quest_duration_min": ("zeitlich", "Minuten", "mittlere Dauer angenommen -> abgeschlossen je Quest"),
    # -- interaktionsbezogen -------------------------------------------------
    "dialogs_started":       ("interaktion", "Anzahl", "Zahl begonnener Dialoge"),
    "dialogs_per_min":       ("interaktion", "1/min", "dialogs_started / playtime_min"),
    "choices_made":          ("interaktion", "Anzahl", "Zahl getroffener Dialogentscheidungen"),
    "quests_added":          ("interaktion", "Anzahl", "Zahl angenommener Quests"),
    "quests_completed":      ("interaktion", "Anzahl", "Zahl abgeschlossener Quests"),
    "quest_completion_ratio": ("interaktion", "Anteil", "quests_completed / max(quests_added, 1)"),
    "scene_changes":         ("interaktion", "Anzahl", "Zahl der Szenenwechsel"),
    "puzzle_starts":         ("interaktion", "Anzahl", "Zahl begonnener Rätsel"),
    "puzzle_solves":         ("interaktion", "Anzahl", "Zahl gelöster Rätsel"),
    "puzzle_solve_ratio":    ("interaktion", "Anteil", "puzzle_solves / max(puzzle_starts, 1)"),
    "items_collected":       ("interaktion", "Anzahl", "Zahl eingesammelter Gegenstände"),
    # -- verhaltensbezogen (abgeleitet, min-max-normiert über alle Sessions) --
    "exploration_index":     ("verhalten", "0..1", "Mittel aus norm(distinct_area_types, path_length_px, explore_time_ratio)"),
    "goal_orientation":      ("verhalten", "0..1", "Mittel aus quest_completion_ratio, puzzle_solve_ratio, 1-norm(mean_quest_duration_min)"),
    "disorientation":        ("verhalten", "0..1", "Mittel aus norm(backtracking_ratio), norm(scene_changes je abgeschl. Quest), 1-norm(quest_completion_ratio)"),
}

# Merkmale, die standardmäßig in den Cluster-Vektor eingehen (Kapitel 5.2 / 5.3).
DEFAULT_CLUSTER_FEATURES: list[str] = [
    "distinct_area_types",
    "path_length_px",
    "explore_time_ratio",
    "playtime_min",
    "mean_quest_duration_min",
    "dialogs_per_min",
    "choices_made",
    "quest_completion_ratio",
    "scene_changes",
    "puzzle_solve_ratio",
    "exploration_index",
    "goal_orientation",
    "disorientation",
]

_MOVE_STATES = {"move", "run", "walk", "sprint"}


@dataclass(slots=True)
class _QuestSpan:
    added_msec: float | None = None
    completed_msec: float | None = None


def _raw_name(event: TelemetryEvent) -> str:
    """Feingranularen Ereignisnamen zurückgeben (der Loader vereinheitlicht z.B.
    quest_added/quest_completed zu quest_updated)."""
    raw = event.raw or {}
    return str(raw.get("event") or raw.get("name") or event.event_type or "")


def _pos(event: TelemetryEvent) -> tuple[float, float] | None:
    if event.position and "x" in event.position and "y" in event.position:
        return float(event.position["x"]), float(event.position["y"])
    if event.x is not None and event.y is not None:
        return float(event.x), float(event.y)
    return None


class SessionFeatureBuilder:
    """Baut aus Telemetrie-Events je Session einen Feature-Vektor."""

    def __init__(self, session_analyzer: SessionAnalyzer | None = None) -> None:
        self.session_analyzer = session_analyzer or SessionAnalyzer()

    # -- öffentliche API --------------------------------------------------
    def build(self, events: list[TelemetryEvent]) -> list[dict[str, float | str]]:
        grouped = self.session_analyzer.group_by_session(events)
        rows: list[dict[str, float | str]] = []
        for session_id, session_events in sorted(grouped.items()):
            row = self._build_session(session_id, session_events)
            if row is not None:
                rows.append(row)
        self._add_behavioural_features(rows)
        return rows

    def feature_names(self) -> list[str]:
        return list(FEATURE_META.keys())

    # -- eine Session ---------------------------------------------------
    def _build_session(
        self, session_id: str, session_events: list[TelemetryEvent]
    ) -> dict[str, float | str] | None:
        ev = sorted(session_events, key=lambda e: e.t_msec)
        if len(ev) < 2:
            return None

        start, end = ev[0].t_msec, ev[-1].t_msec
        playtime_min = max(end - start, 0.0) / 60000.0
        if playtime_min <= 0:
            return None

        # --- Zähler ---------------------------------------------------
        rooms_seen: list[str] = []
        area_types_seen: set[str] = set()
        entries = 0
        revisits = 0
        transitions = 0
        backtracks = 0
        visited_rooms: set[str] = set()

        move_msec = 0.0
        idle_msec = 0.0
        explore_msec = 0.0
        total_dwell_msec = 0.0

        path_len = 0.0
        n_move_samples = 0
        last_move_pos: tuple[float, float] | None = None
        last_move_room: str | None = None

        dialogs_started = 0
        choices_made = 0
        scene_changes = 0
        puzzle_starts = 0
        puzzle_solves = 0
        items_collected = 0

        quest_spans: dict[str, _QuestSpan] = defaultdict(_QuestSpan)
        first_quest_completed_msec: float | None = None

        current_room: str | None = ev[0].room
        if current_room:
            rooms_seen.append(current_room)
            visited_rooms.add(current_room)
            area_types_seen.add(area_type_for(current_room))
            entries += 1

        for i, cur in enumerate(ev):
            nxt = ev[i + 1] if i + 1 < len(ev) else None
            dt = max(nxt.t_msec - cur.t_msec, 0.0) if nxt is not None else 0.0
            room = cur.room or current_room
            if room:
                total_dwell_msec += dt
                if area_type_for(room) == AUSSEN:
                    explore_msec += dt

            name = _raw_name(cur)
            etype = cur.event_type

            if etype == "movement_sample":
                n_move_samples += 1
                state = str((cur.metadata or {}).get("state", "")).lower()
                if state in _MOVE_STATES:
                    move_msec += dt
                else:
                    idle_msec += dt
                p = _pos(cur)
                if p is not None:
                    if last_move_pos is not None and last_move_room == room:
                        path_len += math.dist(p, last_move_pos)
                    last_move_pos, last_move_room = p, room
            else:
                idle_msec += dt

            if etype == "scene_changed":
                scene_changes += 1
                to_room = (cur.metadata or {}).get("to_room") or (nxt.room if nxt is not None else None)
                if to_room:
                    transitions += 1
                    entries += 1
                    if to_room in visited_rooms:
                        revisits += 1
                        backtracks += 1
                    visited_rooms.add(to_room)
                    rooms_seen.append(str(to_room))
                    area_types_seen.add(area_type_for(to_room))
                    current_room = str(to_room)

            if name == "dialog_started":
                dialogs_started += 1
            elif etype == "dialog_choice" or name == "dialog_choice":
                choices_made += 1
            elif name in ("puzzle_started",):
                puzzle_starts += 1
            elif name in ("puzzle_ended", "puzzle_solved", "puzzle_finished"):
                result = str((cur.metadata or {}).get("result", "")).lower()
                if result in ("", "solved", "success", "completed"):
                    puzzle_solves += 1
            elif etype == "item_collected" or name == "item_collected":
                items_collected += 1

            if name in ("quest_added", "quest_started"):
                qid = str((cur.metadata or {}).get("quest_id", "") or name)
                if quest_spans[qid].added_msec is None:
                    quest_spans[qid].added_msec = cur.t_msec
            elif name == "quest_completed":
                qid = str((cur.metadata or {}).get("quest_id", "") or name)
                quest_spans[qid].completed_msec = cur.t_msec
                if first_quest_completed_msec is None:
                    first_quest_completed_msec = cur.t_msec

        # letztes Event ebenfalls auf Bereichstyp abbilden
        if ev[-1].room:
            area_types_seen.add(area_type_for(ev[-1].room))

        quests_added = sum(1 for s in quest_spans.values() if s.added_msec is not None)
        quests_completed = sum(1 for s in quest_spans.values() if s.completed_msec is not None)
        durations = [
            (s.completed_msec - s.added_msec) / 60000.0
            for s in quest_spans.values()
            if s.added_msec is not None and s.completed_msec is not None and s.completed_msec >= s.added_msec
        ]
        mean_quest_duration_min = sum(durations) / len(durations) if durations else 0.0
        time_to_first_quest_min = (
            (first_quest_completed_msec - start) / 60000.0 if first_quest_completed_msec is not None else 0.0
        )

        explore_time_ratio = explore_msec / total_dwell_msec if total_dwell_msec > 0 else 0.0
        revisit_ratio = revisits / entries if entries > 0 else 0.0
        backtracking_ratio = backtracks / transitions if transitions > 0 else 0.0

        return {
            "session_id": session_id,
            "distinct_areas": float(len(set(rooms_seen))),
            "distinct_area_types": float(len({a for a in area_types_seen if a != "unbekannt"})),
            "path_length_px": round(path_len, 2),
            "mean_step_px": round(path_len / n_move_samples, 2) if n_move_samples else 0.0,
            "revisit_ratio": round(revisit_ratio, 4),
            "backtracking_ratio": round(backtracking_ratio, 4),
            "playtime_min": round(playtime_min, 4),
            "move_time_min": round(move_msec / 60000.0, 4),
            "idle_time_min": round(idle_msec / 60000.0, 4),
            "explore_time_ratio": round(explore_time_ratio, 4),
            "time_to_first_quest_min": round(time_to_first_quest_min, 4),
            "mean_quest_duration_min": round(mean_quest_duration_min, 4),
            "dialogs_started": float(dialogs_started),
            "dialogs_per_min": round(dialogs_started / playtime_min, 4),
            "choices_made": float(choices_made),
            "quests_added": float(quests_added),
            "quests_completed": float(quests_completed),
            "quest_completion_ratio": round(quests_completed / max(quests_added, 1), 4),
            "scene_changes": float(scene_changes),
            "puzzle_starts": float(puzzle_starts),
            "puzzle_solves": float(puzzle_solves),
            "puzzle_solve_ratio": round(puzzle_solves / max(puzzle_starts, 1), 4),
            "items_collected": float(items_collected),
        }

    # -- verhaltensbezogene Ebene (braucht alle Sessions) ------------------
    def _add_behavioural_features(self, rows: list[dict[str, float | str]]) -> None:
        if not rows:
            return

        def norm(key: str) -> dict[str, float]:
            vals = [float(r.get(key, 0.0)) for r in rows]
            lo, hi = min(vals), max(vals)
            span = hi - lo
            return {
                str(r["session_id"]): (float(r.get(key, 0.0)) - lo) / span if span > 1e-12 else 0.0
                for r in rows
            }

        n_area_types = norm("distinct_area_types")
        n_path = norm("path_length_px")
        n_explore = norm("explore_time_ratio")
        n_quest_dur = norm("mean_quest_duration_min")
        n_backtrack = norm("backtracking_ratio")

        # Szenenwechsel je abgeschlossener Quest
        for r in rows:
            r["_sc_per_quest"] = float(r["scene_changes"]) / max(float(r["quests_completed"]), 1.0)
        n_sc_per_quest = norm("_sc_per_quest")

        for r in rows:
            sid = str(r["session_id"])
            exploration = (n_area_types[sid] + n_path[sid] + n_explore[sid]) / 3.0
            goal = (
                float(r["quest_completion_ratio"])
                + float(r["puzzle_solve_ratio"])
                + (1.0 - n_quest_dur[sid])
            ) / 3.0
            disorientation = (
                n_backtrack[sid]
                + n_sc_per_quest[sid]
                + (1.0 - float(r["quest_completion_ratio"]))
            ) / 3.0
            r["exploration_index"] = round(exploration, 4)
            r["goal_orientation"] = round(goal, 4)
            r["disorientation"] = round(disorientation, 4)
            del r["_sc_per_quest"]
