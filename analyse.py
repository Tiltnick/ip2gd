#!/usr/bin/env python3
"""
analyse.py  –  Semantische State-Graph-Analyse für Godot-Spiellogs
               Playtracer-Vorbereitung nach Liu et al. (FDG 2011)

Erwartet JSONL-Logs mit mindestens einem dieser Formate:
  Format A (enriched): { session_id, attempt_id, state_hash, state_features, t_msec, ... }
  Format B (existing): { type:"semantic", session_id, state:{...}, context, t_msec, ... }

Ausgabe (--out-dir):
  nodes.csv          – Metriken pro Zustand
  edges.csv          – Metriken pro Übergang
  trajectories.json  – Vollständige Zustandsfolgen pro Attempt
  summary.json       – Gesamtstatistik + Kohorten + Loops + Aha-States
  graph.gexf         – Optional (--gexf), benötigt networkx

Aufruf:
  python analyse.py --log-dir <pfad> --out-dir <pfad>
  python analyse.py --log-dir <pfad> --out-dir <pfad> --scene spaceship
  python analyse.py --log-dir <pfad> --out-dir <pfad> --puzzle Spaceship_code
  python analyse.py --log-dir <pfad> --out-dir <pfad> --features puzzle_core
  python analyse.py --log-dir <pfad> --out-dir <pfad> --gexf

Neues Feature-Set hinzufügen:
  1. Funktion def _features_myname(state: dict) -> dict definieren
  2. In FEATURE_EXTRACTORS registrieren: "myname": _features_myname
  3. Mit --features myname aufrufen
"""

import argparse
import csv
import glob
import hashlib
import json
import os
import sys
import warnings
from collections import Counter, defaultdict
from typing import Dict, List, Optional, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.colors as mcolors
import numpy as np

try:
    from sklearn.manifold import MDS
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False

VERSION = "1.1.0"

KNOWN_OUTCOMES = {"solved", "failed", "abandoned", "closed"}

# ══════════════════════════════════════════════════════════════════════════════
# FEATURE-SET-DEFINITIONEN
# Jede Funktion extrahiert ein dict { feature_key: True } aus einem state-Dict.
# state-Dict = row["state"] aus type:"semantic" Zeilen.
# ══════════════════════════════════════════════════════════════════════════════

def _features_all(state: dict) -> dict:
    """Alle semantischen Features: Quests, Rätsel, Items, Tutorial, NPC."""
    f = {}
    for q in state.get("completed_quests", []):
        f[f"quest:{q}"] = True
    for flag in ("stone_puzzle_solved", "color_code_solved", "statue_puzzle_solved",
                 "temple_puzzle_solved", "all_tripods_interacted", "treasure_chest_solved"):
        if state.get(flag):
            f[flag] = True
    for flag in ("map_collected", "diary_collected", "shovel_collected"):
        if state.get(flag):
            f[flag] = True
    if state.get("tutorial_done"):
        f["tutorial_done"] = True
    stage = state.get("mr_blob_dialog_stage", 0)
    if stage:
        f[f"mr_blob:{stage}"] = True
    return f


def _features_quests(state: dict) -> dict:
    """Nur abgeschlossene Quests."""
    return {f"quest:{q}": True for q in state.get("completed_quests", [])}


def _features_puzzles(state: dict) -> dict:
    """Nur Rätsel-Fortschritts-Flags."""
    f = {}
    for flag in ("stone_puzzle_solved", "color_code_solved", "statue_puzzle_solved",
                 "temple_puzzle_solved", "all_tripods_interacted", "treasure_chest_solved"):
        if state.get(flag):
            f[flag] = True
    return f


def _features_items(state: dict) -> dict:
    """Nur gesammelte Items und Tutorial."""
    f = {}
    for flag in ("map_collected", "diary_collected", "shovel_collected"):
        if state.get(flag):
            f[flag] = True
    if state.get("tutorial_done"):
        f["tutorial_done"] = True
    return f


def _features_puzzle_core(state: dict) -> dict:
    """Quests + Rätsel – kompakt für Puzzle-Analyse."""
    return {**_features_quests(state), **_features_puzzles(state)}


def _features_puzzle_and_dialog(state: dict) -> dict:
    """Quests + Rätsel + NPC-Gesprächsstand."""
    f = _features_puzzle_core(state)
    stage = state.get("mr_blob_dialog_stage", 0)
    if stage:
        f[f"mr_blob:{stage}"] = True
    return f


# Registry: Name → Extraktionsfunktion (hier neue Sets eintragen)
FEATURE_EXTRACTORS = {
    "all":               _features_all,
    "quests":            _features_quests,
    "puzzles":           _features_puzzles,
    "items":             _features_items,
    "puzzle_core":       _features_puzzle_core,
    "puzzle_and_dialog": _features_puzzle_and_dialog,
}


# ══════════════════════════════════════════════════════════════════════════════
# HILFSFUNKTIONEN
# ══════════════════════════════════════════════════════════════════════════════

def _hash_features(features: dict) -> str:
    """Deterministischer 10-Zeichen-Hash aus einem features-Dict."""
    canonical = json.dumps(features, sort_keys=True, separators=(",", ":"))
    return hashlib.md5(canonical.encode()).hexdigest()[:10]


def _warn(msg: str):
    print(f"  WARNUNG: {msg}", file=sys.stderr)


def _serialize_json(obj):
    """JSON-Serialisierer für Sets und Counter."""
    if isinstance(obj, (set, frozenset)):
        return sorted(obj)
    if isinstance(obj, Counter):
        return dict(obj)
    raise TypeError(f"Nicht serialisierbar: {type(obj)}")


# ══════════════════════════════════════════════════════════════════════════════
# A) LOGS LADEN
# ══════════════════════════════════════════════════════════════════════════════

def load_logs(log_dir: str) -> Tuple[List[dict], dict]:
    """
    Lädt alle .jsonl-Dateien aus log_dir (oder eine einzelne Datei).
    Protokolliert beschädigte Zeilen mit Warnung statt sie still zu ignorieren.
    Gibt (rows, load_stats) zurück.
    """
    if os.path.isfile(log_dir):
        files = [log_dir]
    else:
        files = sorted(glob.glob(os.path.join(log_dir, "*.jsonl")))

    if not files:
        print(f"Keine .jsonl-Dateien in '{log_dir}' gefunden.", file=sys.stderr)
        sys.exit(1)

    rows = []
    stats = {"files": 0, "total_lines": 0, "parse_errors": 0}

    for filepath in files:
        stats["files"] += 1
        file_errors = 0
        with open(filepath, "r", encoding="utf-8") as fh:
            for lineno, raw in enumerate(fh, 1):
                raw = raw.strip()
                if not raw:
                    continue
                stats["total_lines"] += 1
                try:
                    rows.append(json.loads(raw))
                except json.JSONDecodeError as exc:
                    stats["parse_errors"] += 1
                    file_errors += 1
                    _warn(f"{os.path.basename(filepath)}:{lineno} – JSON-Fehler: {exc.msg}")
        tag = f"({file_errors} Fehler)" if file_errors else "OK"
        print(f"  {os.path.basename(filepath)}: {tag}")

    return rows, stats


# ══════════════════════════════════════════════════════════════════════════════
# B) VALIDIERUNG
# ══════════════════════════════════════════════════════════════════════════════

def validate_rows(rows: List[dict]) -> Tuple[List[dict], dict]:
    """
    Prüft jede Zeile auf Mindestfelder (session_id + t_msec).
    Gibt (valid_rows, validation_stats) zurück.
    Fasst fehlende Felder zusammen statt einer Warnung pro Zeile.
    """
    valid = []
    stats: Dict = {"valid": 0, "incomplete": 0}
    missing_counter: Counter = Counter()

    for row in rows:
        # Format A: explizite state_hash Felder vorhanden
        if "state_hash" in row:
            required = {"session_id", "state_hash", "state_features", "t_msec"}
        else:
            required = {"session_id", "t_msec"}

        missing = required - row.keys()
        if missing:
            stats["incomplete"] += 1
            for field in missing:
                missing_counter[field] += 1
        else:
            stats["valid"] += 1
            valid.append(row)

    if missing_counter:
        top = dict(missing_counter.most_common(5))
        print(f"  Häufig fehlende Felder: {top}")

    return valid, stats


# ══════════════════════════════════════════════════════════════════════════════
# FEATURE-EXTRAKTION AUS EINER LOGZEILE
# ══════════════════════════════════════════════════════════════════════════════

def extract_state_from_row(row: dict, extractor) -> Optional[Tuple[str, dict]]:
    """
    Extrahiert (state_hash, state_features) aus einer Logzeile.
    Format A: state_hash + state_features direkt vorhanden.
    Format B: type:"semantic" mit verschachteltem state-Dict.
    Gibt None zurück wenn kein Zustand ableitbar.
    """
    # Format A: explizite Felder
    if "state_hash" in row and "state_features" in row:
        raw = row["state_features"]
        if isinstance(raw, str):
            try:
                raw = json.loads(raw)
            except json.JSONDecodeError:
                raw = {}
        features = extractor(raw)
        return row["state_hash"], features

    # Format B: type:"semantic" mit state-Dict
    if row.get("type") == "semantic" and isinstance(row.get("state"), dict):
        features = extractor(row["state"])
        return _hash_features(features), features

    return None


# ══════════════════════════════════════════════════════════════════════════════
# C) ATTEMPT-SEQUENZEN AUFBAUEN
# ══════════════════════════════════════════════════════════════════════════════

def build_attempt_sequences(
    rows: List[dict],
    extractor,
    filter_scene: Optional[str] = None,
    filter_puzzle: Optional[str] = None,
) -> List[dict]:
    """
    Baut pro Attempt eine Zustandsfolge auf.
    Attempt-Granularität:
      - Mit --puzzle: puzzle_started → puzzle_ended Paare
      - Mit expliziter attempt_id im Log: nach attempt_id gruppiert
      - Sonst: komplette Session = ein Attempt

    Jeder Attempt ist ein Dict:
    {
        attempt_id, session_id, scene, puzzle_id, outcome, duration_ms,
        sequence: [{ state_hash, state_features, t_msec, event, scene }, ...]
    }
    """
    by_session: Dict[str, List[dict]] = defaultdict(list)
    for row in rows:
        by_session[row.get("session_id", "unknown")].append(row)

    attempts = []

    for sid, session_rows in sorted(by_session.items()):
        session_rows.sort(key=lambda r: r.get("t_msec", 0))

        if filter_puzzle:
            # Puzzle-Modus: Attempts an puzzle_started/puzzle_ended schneiden
            _extract_puzzle_attempts(
                session_rows, sid, filter_puzzle, extractor, filter_scene, attempts
            )
        elif session_rows and "attempt_id" in session_rows[0]:
            # Format A mit expliziter attempt_id
            by_attempt: Dict[str, List[dict]] = defaultdict(list)
            for row in session_rows:
                by_attempt[row.get("attempt_id", sid)].append(row)
            for aid, att_rows in sorted(by_attempt.items()):
                att = _build_single_attempt(att_rows, sid, aid, extractor, filter_scene)
                if att:
                    attempts.append(att)
        else:
            # Session als ganzer Attempt
            att = _build_single_attempt(session_rows, sid, sid, extractor, filter_scene)
            if att:
                attempts.append(att)

    return attempts


def _extract_puzzle_attempts(
    session_rows: List[dict],
    sid: str,
    puzzle_filter: str,
    extractor,
    filter_scene: Optional[str],
    out: list,
):
    """Schneide Session an puzzle_started/puzzle_ended Paaren für puzzle_filter."""
    in_puzzle = False
    puzzle_rows: List[dict] = []
    puzzle_start_t = 0
    puzzle_outcome = "unknown"

    for row in session_rows:
        rtype = row.get("type", "")
        pid   = row.get("puzzle_id", row.get("puzzle", row.get("title", "")))

        if rtype == "puzzle_started" and pid == puzzle_filter:
            in_puzzle      = True
            puzzle_rows    = [row]
            puzzle_start_t = row.get("t_msec", 0)
            puzzle_outcome = "unknown"

        elif rtype == "puzzle_ended" and pid == puzzle_filter and in_puzzle:
            puzzle_rows.append(row)
            result = row.get("result", "unknown")
            puzzle_outcome = result if result in KNOWN_OUTCOMES else "unknown"
            att = _build_single_attempt(
                puzzle_rows, sid,
                f"{sid}_{puzzle_filter}_{puzzle_start_t}",
                extractor, filter_scene,
            )
            if att:
                att["outcome"]    = puzzle_outcome
                att["puzzle_id"]  = puzzle_filter
                out.append(att)
            in_puzzle    = False
            puzzle_rows  = []

        elif in_puzzle:
            puzzle_rows.append(row)


def _build_single_attempt(
    rows: List[dict],
    sid: str,
    aid: str,
    extractor,
    filter_scene: Optional[str],
) -> Optional[dict]:
    """
    Baut ein Attempt-Dict aus einer sortierten Zeilenliste.
    Filtert optional nach Szene (Teilstring-Match).
    Duplikate (gleicher state_hash in Folge) werden übersprungen.
    """
    sequence  = []
    outcome   = "unknown"
    scene     = None
    puzzle_id = None
    last_hash = None

    for row in rows:
        rtype     = row.get("type", "")
        t         = row.get("t_msec", 0)
        row_scene = (
            row.get("scene")
            or row.get("to")  # scene_changed
            or (row.get("state") or {}).get("current_area")
        )

        # Szenenfilter: Teilstring-Match, case-insensitiv
        if filter_scene and row_scene:
            if filter_scene.lower() not in row_scene.lower():
                continue
        if row_scene:
            scene = row_scene

        # Puzzle-ID merken
        pid = row.get("puzzle_id", row.get("puzzle"))
        if pid:
            puzzle_id = pid

        # Outcome aus puzzle_ended
        if rtype == "puzzle_ended":
            result = row.get("result", "unknown")
            if result in KNOWN_OUTCOMES:
                outcome = result

        # Zustand extrahieren
        state_tup = extract_state_from_row(row, extractor)
        if state_tup is None:
            continue

        state_hash, state_features = state_tup
        if state_hash == last_hash:
            continue  # kein Fortschritt im Zustandsraum

        last_hash = state_hash
        sequence.append({
            "state_hash":     state_hash,
            "state_features": state_features,
            "t_msec":         t,
            "event":          row.get("event", row.get("context", rtype)),
            "scene":          row_scene,
        })

    if not sequence:
        return None

    duration = sequence[-1]["t_msec"] - sequence[0]["t_msec"]
    return {
        "attempt_id":  aid,
        "session_id":  sid,
        "scene":       scene,
        "puzzle_id":   puzzle_id,
        "outcome":     outcome,
        "duration_ms": max(0, duration),
        "sequence":    sequence,
    }


# ══════════════════════════════════════════════════════════════════════════════
# D) STATE GRAPH AUFBAUEN
# ══════════════════════════════════════════════════════════════════════════════

def build_state_graph(attempts: List[dict]) -> Tuple[dict, dict]:
    """
    Erstellt gerichteten State-Graphen aus Attempt-Sequenzen.
    Knoten = state_hash, Kanten = Übergänge.
    Gibt (nodes, edges) zurück – beide als Dicts, Sets/Counter noch intern.
    """
    nodes: Dict[str, dict] = {}
    edges: Dict[Tuple[str, str], dict] = {}

    for att in attempts:
        sid     = att["session_id"]
        aid     = att["attempt_id"]
        outcome = att["outcome"]
        scene   = att["scene"]
        pid     = att["puzzle_id"]
        seq     = att["sequence"]

        for i, step in enumerate(seq):
            h  = step["state_hash"]
            sf = step["state_features"]

            if h not in nodes:
                nodes[h] = {
                    "state_hash":      h,
                    "sample_features": sf,      # repräsentatives Beispiel
                    "visit_count":     0,
                    "unique_sessions": set(),
                    "unique_attempts": set(),
                    "scenes":          set(),
                    "puzzle_ids":      set(),
                    "is_start_state":  False,
                    "is_goal_state":   False,
                    "outcome_counts":  Counter(),  # welche Outcomes folgten diesem Besuch
                    "time_spent_ms":   [],         # Verweildauer-Samples (ms)
                }

            nd = nodes[h]
            nd["visit_count"]     += 1
            nd["unique_sessions"].add(sid)
            nd["unique_attempts"].add(aid)
            if scene:  nd["scenes"].add(scene)
            if pid:    nd["puzzle_ids"].add(pid)
            nd["outcome_counts"][outcome] += 1

            # Verweildauer: Δt zum nächsten Schritt
            if i < len(seq) - 1:
                dt = seq[i + 1]["t_msec"] - step["t_msec"]
                if dt >= 0:
                    nd["time_spent_ms"].append(dt)

            # Start-/Zielzustand markieren
            if i == 0:
                nd["is_start_state"] = True
            if i == len(seq) - 1 and outcome == "solved":
                nd["is_goal_state"] = True

            # Kante anlegen / aktualisieren
            if i > 0:
                prev_h = seq[i - 1]["state_hash"]
                key    = (prev_h, h)
                if key not in edges:
                    edges[key] = {
                        "source":           prev_h,
                        "target":           h,
                        "transition_count": 0,
                        "trigger_events":   Counter(),
                        "transition_times": [],
                        "outcome_counts":   Counter(),
                    }
                ed = edges[key]
                ed["transition_count"] += 1
                ed["trigger_events"][step["event"]] += 1
                dt_edge = step["t_msec"] - seq[i - 1]["t_msec"]
                if dt_edge >= 0:
                    ed["transition_times"].append(dt_edge)
                ed["outcome_counts"][outcome] += 1

    return nodes, edges


# ══════════════════════════════════════════════════════════════════════════════
# E) OUTCOMES KLASSIFIZIEREN
# ══════════════════════════════════════════════════════════════════════════════

def classify_outcomes(attempts: List[dict]) -> Dict[str, List[dict]]:
    """Teilt Attempts in Kohorten: solved / failed / abandoned / unknown."""
    cohorts: Dict[str, List[dict]] = defaultdict(list)
    for att in attempts:
        cohorts[att["outcome"]].append(att)
    return dict(cohorts)


# ══════════════════════════════════════════════════════════════════════════════
# F) KNOTEN-METRIKEN BERECHNEN
# ══════════════════════════════════════════════════════════════════════════════

def compute_node_metrics(nodes: dict, attempts: List[dict]) -> dict:
    """
    Ergänzt jeden Knoten um:
    - solve_rate_after_visit / quit_rate / fail_rate
    - avg_time_spent_ms
    - median_remaining_steps_to_goal
    Mutiert nodes in-place.
    """
    # solve_rate / quit_rate / fail_rate aus outcome_counts
    for h, nd in nodes.items():
        oc    = nd["outcome_counts"]
        total = sum(oc.values())
        nd["solve_rate_after_visit"] = oc.get("solved",    0) / total if total else 0.0
        nd["quit_rate_after_visit"]  = oc.get("abandoned", 0) / total if total else 0.0
        nd["fail_rate_after_visit"]  = oc.get("failed",    0) / total if total else 0.0

        times = nd["time_spent_ms"]
        nd["avg_time_spent_ms"] = sum(times) / len(times) if times else 0.0

    # Median verbleibende Schritte bis Ziel (nur in solved Attempts)
    steps_to_goal: Dict[str, List[int]] = defaultdict(list)
    for att in attempts:
        if att["outcome"] != "solved":
            continue
        seq = att["sequence"]
        n   = len(seq)
        for i, step in enumerate(seq):
            steps_to_goal[step["state_hash"]].append(n - 1 - i)

    for h, nd in nodes.items():
        stg = sorted(steps_to_goal.get(h, []))
        nd["median_remaining_steps_to_goal"] = stg[len(stg) // 2] if stg else None

    return nodes


# ══════════════════════════════════════════════════════════════════════════════
# G) KANTEN-METRIKEN BERECHNEN
# ══════════════════════════════════════════════════════════════════════════════

def compute_edge_metrics(edges: dict) -> dict:
    """
    Ergänzt Kanten um:
    - transition_probability (relativ zu anderen Ausgängen desselben Quellknotens)
    - avg_transition_time_ms
    - successful_transition_rate
    - dominant_trigger_event
    Mutiert edges in-place.
    """
    # Ausgangsgrad pro Quellknoten
    out_count: Counter = Counter()
    for (src, _), ed in edges.items():
        out_count[src] += ed["transition_count"]

    for (src, dst), ed in edges.items():
        total_from_src = out_count[src]
        ed["transition_probability"] = (
            ed["transition_count"] / total_from_src if total_from_src > 0 else 0.0
        )

        times = ed["transition_times"]
        ed["avg_transition_time_ms"] = sum(times) / len(times) if times else 0.0

        oc    = ed["outcome_counts"]
        total = sum(oc.values())
        ed["successful_transition_rate"] = oc.get("solved", 0) / total if total else 0.0

        ed["dominant_trigger_event"] = (
            ed["trigger_events"].most_common(1)[0][0]
            if ed["trigger_events"] else ""
        )

    return edges


# ══════════════════════════════════════════════════════════════════════════════
# H) SOLVER VS. ABBRECHER VERGLEICHEN
# ══════════════════════════════════════════════════════════════════════════════

def compare_cohorts(attempts: List[dict], nodes: dict) -> dict:
    """
    Vergleicht solved-, abandoned- und failed-Kohorten.
    Berechnet pro Kohorte: Anzahl, Ø-Dauer, Ø-Sequenzlänge, Top-States, Top-Transitions.
    Identifiziert States die stark mit Erfolg bzw. Abbruch korrelieren.
    """
    cohorts = classify_outcomes(attempts)

    def _state_freq(cohort_attempts: List[dict]) -> Counter:
        freq: Counter = Counter()
        for att in cohort_attempts:
            for step in att["sequence"]:
                freq[step["state_hash"]] += 1
        return freq

    def _transition_freq(cohort_attempts: List[dict]) -> Counter:
        freq: Counter = Counter()
        for att in cohort_attempts:
            seq = att["sequence"]
            for i in range(1, len(seq)):
                freq[(seq[i-1]["state_hash"], seq[i]["state_hash"])] += 1
        return freq

    result: dict = {}
    for outcome in ("solved", "abandoned", "failed", "unknown"):
        cohort = cohorts.get(outcome, [])
        if not cohort:
            result[outcome] = {"count": 0}
            continue

        sf = _state_freq(cohort)
        tf = _transition_freq(cohort)
        result[outcome] = {
            "count":               len(cohort),
            "avg_duration_ms":     sum(a["duration_ms"] for a in cohort) / len(cohort),
            "avg_sequence_length": sum(len(a["sequence"]) for a in cohort) / len(cohort),
            "top_states": [
                {
                    "state_hash": h,
                    "count":      c,
                    "features":   nodes.get(h, {}).get("sample_features", {}),
                }
                for h, c in sf.most_common(10)
            ],
            "top_transitions": [
                {"from": src, "to": dst, "count": c}
                for (src, dst), c in tf.most_common(10)
            ],
        }

    # States die nur bei Solvern bzw. nur bei Abbrechern auftauchen
    solved_hashes    = {step["state_hash"] for a in cohorts.get("solved",    []) for step in a["sequence"]}
    abandoned_hashes = {step["state_hash"] for a in cohorts.get("abandoned", []) for step in a["sequence"]}
    result["success_indicators"] = sorted(solved_hashes    - abandoned_hashes)
    result["abandon_indicators"]  = sorted(abandoned_hashes - solved_hashes)
    result["shared_states"]       = sorted(solved_hashes    & abandoned_hashes)

    return result


# ══════════════════════════════════════════════════════════════════════════════
# I) LOOPS UND SACKGASSEN ERKENNEN
# ══════════════════════════════════════════════════════════════════════════════

def detect_loops(attempts: List[dict]) -> List[dict]:
    """
    Erkennt Zustände die innerhalb eines Attempts mehrfach besucht werden (Revisits).
    Gibt die Top-20 revisited states zurück, sortiert nach Häufigkeit.
    """
    revisit_counter: Counter = Counter()

    for att in attempts:
        seen: set = set()
        for step in att["sequence"]:
            h = step["state_hash"]
            if h in seen:
                revisit_counter[h] += 1
            seen.add(h)

    return [
        {"state_hash": h, "revisit_count": c}
        for h, c in revisit_counter.most_common(20)
    ]


def detect_dead_ends(nodes: dict) -> List[str]:
    """
    Markiert Dead-End-Kandidaten:
    - Mindestens 3 Besuche
    - solve_rate_after_visit < 0.2
    - quit_rate_after_visit  > 0.4
    Setzt nodes[h]["is_dead_end_candidate"] und gibt die Hash-Liste zurück.
    """
    dead_ends = []
    for h, nd in nodes.items():
        is_dead = (
            nd["visit_count"]            >= 3
            and nd["solve_rate_after_visit"] < 0.2
            and nd["quit_rate_after_visit"]  > 0.4
        )
        nd["is_dead_end_candidate"] = is_dead
        if is_dead:
            dead_ends.append(h)
    return dead_ends


# ══════════════════════════════════════════════════════════════════════════════
# J) AHA-MOMENTE SCHÄTZEN
# ══════════════════════════════════════════════════════════════════════════════

def detect_aha_states(
    nodes: dict,
    attempts: List[dict],
    solve_rate_jump: float = 0.3,
) -> List[str]:
    """
    Erkennt Zustände nach denen die Erfolgswahrscheinlichkeit deutlich steigt.
    Kriterium: solve_rate >= mittlere solve_rate + solve_rate_jump
    Setzt nodes[h]["is_aha_candidate"] und gibt die Hash-Liste zurück.
    """
    rates = [
        nd["solve_rate_after_visit"]
        for nd in nodes.values()
        if nd["visit_count"] >= 2
    ]
    mean_rate = sum(rates) / len(rates) if rates else 0.0

    aha_states = []
    for h, nd in nodes.items():
        if nd["visit_count"] < 2:
            nd["is_aha_candidate"] = False
            continue
        sr      = nd["solve_rate_after_visit"]
        is_aha  = sr >= solve_rate_jump and sr >= mean_rate + solve_rate_jump
        nd["is_aha_candidate"] = is_aha
        if is_aha:
            aha_states.append(h)

    return aha_states


# ══════════════════════════════════════════════════════════════════════════════
# L) EXPORT
# ══════════════════════════════════════════════════════════════════════════════

def export_nodes_edges(nodes: dict, edges: dict, out_dir: str):
    """
    Exportiert nodes.csv und edges.csv.
    Alle Sets werden zu |-getrennten Strings, features zu JSON.
    """
    os.makedirs(out_dir, exist_ok=True)

    # ── nodes.csv ─────────────────────────────────────────────────────────────
    nodes_path = os.path.join(out_dir, "nodes.csv")
    node_fields = [
        "state_hash", "visit_count", "unique_sessions", "unique_attempts",
        "solve_rate_after_visit", "quit_rate_after_visit", "fail_rate_after_visit",
        "avg_time_spent_ms", "median_remaining_steps_to_goal",
        "is_start_state", "is_goal_state", "is_dead_end_candidate", "is_aha_candidate",
        "scenes", "puzzle_ids", "sample_features_json",
    ]
    with open(nodes_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=node_fields)
        w.writeheader()
        for h, nd in nodes.items():
            w.writerow({
                "state_hash":                     h,
                "visit_count":                    nd["visit_count"],
                "unique_sessions":                len(nd["unique_sessions"]),
                "unique_attempts":                len(nd["unique_attempts"]),
                "solve_rate_after_visit":         round(nd.get("solve_rate_after_visit", 0), 4),
                "quit_rate_after_visit":          round(nd.get("quit_rate_after_visit",  0), 4),
                "fail_rate_after_visit":          round(nd.get("fail_rate_after_visit",  0), 4),
                "avg_time_spent_ms":              round(nd.get("avg_time_spent_ms", 0), 1),
                "median_remaining_steps_to_goal": nd.get("median_remaining_steps_to_goal"),
                "is_start_state":                 nd["is_start_state"],
                "is_goal_state":                  nd["is_goal_state"],
                "is_dead_end_candidate":          nd.get("is_dead_end_candidate", False),
                "is_aha_candidate":               nd.get("is_aha_candidate", False),
                "scenes":                         "|".join(sorted(nd["scenes"])),
                "puzzle_ids":                     "|".join(sorted(nd["puzzle_ids"])),
                "sample_features_json":           json.dumps(
                    nd["sample_features"], ensure_ascii=False, sort_keys=True
                ),
            })
    print(f"  nodes.csv        → {nodes_path}")

    # ── edges.csv ─────────────────────────────────────────────────────────────
    edges_path = os.path.join(out_dir, "edges.csv")
    edge_fields = [
        "source", "target", "transition_count", "transition_probability",
        "avg_transition_time_ms", "successful_transition_rate", "dominant_trigger_event",
    ]
    with open(edges_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=edge_fields)
        w.writeheader()
        for (src, dst), ed in edges.items():
            w.writerow({
                "source":                    src,
                "target":                    dst,
                "transition_count":          ed["transition_count"],
                "transition_probability":    round(ed.get("transition_probability",    0), 4),
                "avg_transition_time_ms":    round(ed.get("avg_transition_time_ms",    0), 1),
                "successful_transition_rate": round(ed.get("successful_transition_rate", 0), 4),
                "dominant_trigger_event":    ed.get("dominant_trigger_event", ""),
            })
    print(f"  edges.csv        → {edges_path}")


def export_trajectories(attempts: List[dict], out_dir: str):
    """
    Exportiert trajectories.json – vollständige Zustandsfolgen pro Attempt.
    Enthält attempt_id, session_id, scene, puzzle_id, outcome, duration_ms und sequence.
    """
    os.makedirs(out_dir, exist_ok=True)
    path    = os.path.join(out_dir, "trajectories.json")
    payload = []
    for att in attempts:
        payload.append({
            "attempt_id":  att["attempt_id"],
            "session_id":  att["session_id"],
            "scene":       att["scene"],
            "puzzle_id":   att["puzzle_id"],
            "outcome":     att["outcome"],
            "duration_ms": att["duration_ms"],
            "sequence": [
                {
                    "state_hash":     s["state_hash"],
                    "t_msec":         s["t_msec"],
                    "event":          s["event"],
                    "scene":          s["scene"],
                    "features":       s["state_features"],
                }
                for s in att["sequence"]
            ],
        })
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False, default=_serialize_json)
    print(f"  trajectories.json → {path}")


def export_summary(
    summary: dict,
    out_dir: str,
    cohorts: dict,
    loops: List[dict],
    dead_ends: List[str],
    aha_states: List[str],
    nodes: dict,
):
    """Exportiert summary.json – Gesamtstatistik inkl. Kohorten, Loops und Aha-States."""
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, "summary.json")

    # Aha-States mit lesbaren Features anreichern
    aha_detail = [
        {
            "state_hash": h,
            "solve_rate": round(nodes[h]["solve_rate_after_visit"], 4),
            "visit_count": nodes[h]["visit_count"],
            "features":   nodes[h]["sample_features"],
        }
        for h in aha_states if h in nodes
    ]

    dead_end_detail = [
        {
            "state_hash": h,
            "quit_rate":  round(nodes[h]["quit_rate_after_visit"], 4),
            "visit_count": nodes[h]["visit_count"],
            "features":   nodes[h]["sample_features"],
        }
        for h in dead_ends if h in nodes
    ]

    data = {
        **summary,
        "cohort_comparison": cohorts,
        "loops_top20":       loops,
        "dead_end_states":   dead_end_detail,
        "aha_states":        aha_detail,
    }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False, default=_serialize_json)
    print(f"  summary.json     → {path}")


def export_gexf(nodes: dict, edges: dict, out_dir: str):
    """
    Exportiert graph.gexf für Gephi / NetworkX-Weiterverarbeitung.
    Benötigt: pip install networkx
    """
    try:
        import networkx as nx
    except ImportError:
        _warn("networkx nicht installiert – GEXF-Export übersprungen.  pip install networkx")
        return

    G = nx.DiGraph()
    for h, nd in nodes.items():
        G.add_node(
            h,
            visit_count  = nd["visit_count"],
            solve_rate   = round(nd.get("solve_rate_after_visit", 0), 4),
            is_start     = int(nd["is_start_state"]),
            is_goal      = int(nd["is_goal_state"]),
            is_dead_end  = int(nd.get("is_dead_end_candidate", False)),
            is_aha       = int(nd.get("is_aha_candidate", False)),
            label        = json.dumps(nd.get("sample_features", {}), ensure_ascii=False),
        )
    for (src, dst), ed in edges.items():
        G.add_edge(
            src, dst,
            weight      = ed["transition_count"],
            probability = round(ed.get("transition_probability", 0), 4),
        )

    path = os.path.join(out_dir, "graph.gexf")
    nx.write_gexf(G, path)
    print(f"  graph.gexf       → {path}")


# ══════════════════════════════════════════════════════════════════════════════
# K) PLAYTRACER-VISUALISIERUNG (nach Liu et al., FDG 2011)
# ══════════════════════════════════════════════════════════════════════════════

def _feature_label(features: dict) -> str:
    """Erzeugt ein kurzes mehrzeiliges Label aus einem features-Dict."""
    parts = []
    for key in sorted(features.keys()):
        if key.startswith("quest:"):
            parts.append(key[6:])
        elif key.startswith("mr_blob:"):
            parts.append(f"blob:{key[8:]}")
        elif key.endswith("_solved"):
            parts.append(key.replace("_solved", "✓").replace("_", ""))
        elif key.endswith("_collected"):
            parts.append(key.replace("_collected", "").replace("_", ""))
        elif key == "tutorial_done":
            parts.append("tut✓")
        else:
            parts.append(key.replace("_", ""))
    return "\n".join(parts) if parts else "∅"


def _state_feature_distance(fa: dict, fb: dict) -> int:
    """Symmetrische Differenz zweier Feature-Dicts (Hamming-Distanz)."""
    keys = set(fa.keys()) | set(fb.keys())
    return sum(1 for k in keys if fa.get(k) != fb.get(k))


def _solve_rate_color(rate: float):
    """Blau (hohe solve_rate) → Rot (niedrige solve_rate) wie in Andersen et al."""
    # rate 1.0 → blue, rate 0.0 → red
    r = 1.0 - rate
    b = rate
    g = 0.2
    return (r, g, b)


def save_playtracer(
    nodes: dict,
    edges: dict,
    attempts: List[dict],
    out_dir: str,
    feature_set: str,
    scene_filter: Optional[str] = None,
    puzzle_filter: Optional[str] = None,
):
    """
    Erzeugt Playtracer-Visualisierungen nach Liu et al. (FDG 2011):
      1) playtracer_all.png     – Alle Spieler, Farbe = solve_rate (blau→rot)
      2) playtracer_winners.png – Nur solved Attempts (blaue Kanten)
      3) playtracer_losers.png  – Nur abandoned/failed Attempts (rote Kanten)
    """
    if not HAS_SKLEARN:
        _warn("scikit-learn nicht installiert – Playtracer-Visualisierung übersprungen.")
        _warn("  pip install scikit-learn")
        return

    os.makedirs(out_dir, exist_ok=True)

    all_hashes = list(nodes.keys())
    n = len(all_hashes)
    if n < 2:
        print(f"  Playtracer: nur {n} Zustand – Visualisierung übersprungen.")
        return

    hash_idx = {h: i for i, h in enumerate(all_hashes)}

    # ── Distanzmatrix (Feature-Hamming) ───────────────────────────────────
    dist_matrix = np.zeros((n, n), dtype=np.float64)
    for i in range(n):
        fi = nodes[all_hashes[i]]["sample_features"]
        for j in range(i + 1, n):
            fj = nodes[all_hashes[j]]["sample_features"]
            d = _state_feature_distance(fi, fj)
            dist_matrix[i, j] = d
            dist_matrix[j, i] = d

    # ── MDS-Layout (Classical MDS wie im Paper) ───────────────────────────
    n_comp = min(2, n - 1)
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", category=FutureWarning)
        mds = MDS(
            n_components=n_comp,
            metric=True,
            dissimilarity="precomputed",
            random_state=42,
            normalized_stress="auto",
            n_init=4,
            init="random",
        )
        emb = mds.fit_transform(dist_matrix)

    if n_comp == 1:
        pos = np.column_stack([emb[:, 0], np.zeros(n)])
    else:
        pos = emb

    max_visits = max(nd["visit_count"] for nd in nodes.values())
    max_trans  = max((ed["transition_count"] for ed in edges.values()), default=1)

    # ── Kanten nach Outcome aufteilen ─────────────────────────────────────
    solved_edges:   Dict[tuple, int] = defaultdict(int)
    failed_edges:   Dict[tuple, int] = defaultdict(int)
    for att in attempts:
        seq = att["sequence"]
        outcome = att["outcome"]
        for i in range(1, len(seq)):
            key = (seq[i-1]["state_hash"], seq[i]["state_hash"])
            if outcome == "solved":
                solved_edges[key] += 1
            else:
                failed_edges[key] += 1

    # ── Plot-Funktion ─────────────────────────────────────────────────────
    def _draw_playtracer(
        ax,
        edge_subset: Optional[dict] = None,
        edge_color: str = "#4466aa",
        color_mode: str = "solve_rate",
        title_suffix: str = "",
    ):
        ax.axis("off")
        ax.set_aspect("equal")

        use_edges = edge_subset if edge_subset is not None else {
            (ed["source"], ed["target"]): ed["transition_count"]
            for ed in edges.values()
        }

        # Kanten zeichnen
        for (src, dst), count in use_edges.items():
            if src not in hash_idx or dst not in hash_idx:
                continue
            ia, ib = hash_idx[src], hash_idx[dst]
            lw    = 0.5 + 4.0 * (count / max_trans)
            alpha = 0.2 + 0.6 * (count / max_trans)
            ax.annotate(
                "",
                xy=pos[ib], xytext=pos[ia],
                arrowprops=dict(
                    arrowstyle="-|>",
                    color=edge_color,
                    lw=lw,
                    alpha=alpha,
                    mutation_scale=10,
                    connectionstyle="arc3,rad=0.15",
                ),
                zorder=2,
            )

        # Knoten zeichnen
        for i, h in enumerate(all_hashes):
            nd    = nodes[h]
            x, y  = pos[i]
            n_vis = nd["visit_count"]
            size  = 80 + 1500 * (n_vis / max_visits)

            # Farbe nach Modus
            if color_mode == "solve_rate":
                sr = nd.get("solve_rate_after_visit", 0)
                fc = _solve_rate_color(sr)
            elif color_mode == "winner":
                fc = "#4488cc"
            elif color_mode == "loser":
                fc = "#cc4444"
            else:
                fc = "#888888"

            # Rand: Gelb=Start, Grün=Ziel, Rot=Dead-End, Lila=Aha
            if nd["is_start_state"] and nd["is_goal_state"]:
                ec, elw = "gold", 3.0
            elif nd["is_start_state"]:
                ec, elw = "gold", 3.0
            elif nd["is_goal_state"]:
                ec, elw = "#00cc44", 3.0
            elif nd.get("is_dead_end_candidate"):
                ec, elw = "#cc0000", 2.5
            elif nd.get("is_aha_candidate"):
                ec, elw = "#cc00cc", 2.5
            else:
                ec, elw = "#333333", 0.5

            ax.scatter(x, y, s=size, c=[fc], edgecolors=ec,
                       linewidths=elw, zorder=5)

            # Feature-Label
            label = _feature_label(nd.get("sample_features", {}))
            ax.text(x, y - 0.06 * (dist_matrix.max() or 1),
                    label, fontsize=5, ha="center", va="top",
                    color="#111111", zorder=7, alpha=0.85)

        # Legende
        handles = [
            mpatches.Patch(facecolor="gold",    edgecolor="#aa8800", label="Startzustand (Entry)"),
            mpatches.Patch(facecolor="#00cc44", edgecolor="#006622", label="Zielzustand (Goal / Solved)"),
        ]
        if color_mode == "solve_rate":
            handles += [
                mpatches.Patch(facecolor=_solve_rate_color(1.0), label="Hohe Erfolgsrate (blau)"),
                mpatches.Patch(facecolor=_solve_rate_color(0.5), label="Mittlere Erfolgsrate"),
                mpatches.Patch(facecolor=_solve_rate_color(0.0), label="Niedrige Erfolgsrate (rot)"),
            ]
        handles += [
            mpatches.Patch(facecolor="white", edgecolor="#cc0000", label="Dead-End-Kandidat", linewidth=2),
            mpatches.Patch(facecolor="white", edgecolor="#cc00cc", label="Aha-Kandidat", linewidth=2),
        ]
        ax.legend(handles=handles, loc="lower right", fontsize=7, framealpha=0.9)

        # Titel
        filter_info = ""
        if scene_filter:  filter_info += f" | Szene: {scene_filter}"
        if puzzle_filter: filter_info += f" | Puzzle: {puzzle_filter}"
        ax.set_title(
            f"Playtracer{title_suffix}  ({len(attempts)} Attempts · {n} Zustände · {len(use_edges)} Übergänge)\n"
            f"Feature-Set: {feature_set} · MDS-Layout · Größe ∝ Besuche{filter_info}",
            fontsize=9,
        )

    # ── 1) Alle Spieler (solve_rate-Färbung) ──────────────────────────────
    fig, ax = plt.subplots(figsize=(12, 10))
    _draw_playtracer(ax, edge_subset=None, edge_color="#4466aa",
                     color_mode="solve_rate", title_suffix="")
    fig.tight_layout()
    path_all = os.path.join(out_dir, "playtracer_all.png")
    fig.savefig(path_all, dpi=150)
    plt.close(fig)
    print(f"  playtracer_all.png   → {path_all}")

    # ── 2) Nur Gewinner (blaue Kanten) ────────────────────────────────────
    if solved_edges:
        fig, ax = plt.subplots(figsize=(12, 10))
        _draw_playtracer(ax, edge_subset=dict(solved_edges), edge_color="#2266cc",
                         color_mode="winner", title_suffix=" – Solver")
        fig.tight_layout()
        path_w = os.path.join(out_dir, "playtracer_winners.png")
        fig.savefig(path_w, dpi=150)
        plt.close(fig)
        print(f"  playtracer_winners.png → {path_w}")

    # ── 3) Nur Verlierer (rote Kanten) ────────────────────────────────────
    if failed_edges:
        fig, ax = plt.subplots(figsize=(12, 10))
        _draw_playtracer(ax, edge_subset=dict(failed_edges), edge_color="#cc2222",
                         color_mode="loser", title_suffix=" – Abbrecher/Fehlgeschlagen")
        fig.tight_layout()
        path_l = os.path.join(out_dir, "playtracer_losers.png")
        fig.savefig(path_l, dpi=150)
        plt.close(fig)
        print(f"  playtracer_losers.png → {path_l}")


# ══════════════════════════════════════════════════════════════════════════════
# CLI / MAIN
# ══════════════════════════════════════════════════════════════════════════════

def _print_summary(summary: dict, loops: list, dead_ends: list, aha_states: list):
    print("\n── Zusammenfassung ──────────────────────────────────────────────────")
    print(f"  Sessions:          {summary['n_sessions']}")
    print(f"  Attempts:          {summary['n_attempts']}")
    print(f"  Eindeutige States: {summary['n_states']}")
    print(f"  Transitions:       {summary['n_transitions']}")
    print(f"  Solved:            {summary['n_solved']}")
    print(f"  Abandoned:         {summary['n_abandoned']}")
    print(f"  Failed:            {summary['n_failed']}")
    print(f"  Unknown:           {summary['n_unknown']}")
    print(f"  Loops (revisited): {len(loops)}")
    print(f"  Dead-End-States:   {len(dead_ends)}")
    print(f"  Aha-States:        {len(aha_states)}")
    print("─────────────────────────────────────────────────────────────────────")


def main():
    parser = argparse.ArgumentParser(
        description="Semantische State-Graph-Analyse für Godot-Spiellogs",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Beispiele:
  python analyse.py --log-dir analytics --out-dir out
  python analyse.py --log-dir analytics --out-dir out --scene spaceship
  python analyse.py --log-dir analytics --out-dir out --puzzle Spaceship_code
  python analyse.py --log-dir analytics --out-dir out --features puzzle_core --gexf
        """,
    )
    parser.add_argument("--log-dir",       required=True,
                        help="Ordner mit .jsonl-Dateien oder Pfad zu einer .jsonl-Datei")
    parser.add_argument("--out-dir",       required=True,
                        help="Ausgabeordner (wird erstellt falls nicht vorhanden)")
    parser.add_argument("--scene",         default=None,
                        help="Filtere nach Szenenname (Teilstring-Match)")
    parser.add_argument("--puzzle",        default=None,
                        help="Filtere nach puzzle_id – Attempts werden an puzzle_started/ended geschnitten")
    parser.add_argument("--features",      default="all",
                        choices=list(FEATURE_EXTRACTORS.keys()),
                        help="Feature-Set für Zustandsdefinition (default: all)")
    parser.add_argument("--aha-threshold", type=float, default=0.3,
                        help="Mindest-Sprung in solve_rate für Aha-Erkennung (default: 0.3)")
    parser.add_argument("--gexf",          action="store_true",
                        help="Exportiere graph.gexf (benötigt networkx)")
    parser.add_argument("--no-viz",        action="store_true",
                        help="Überspringe Playtracer-Visualisierung")
    args = parser.parse_args()

    extractor = FEATURE_EXTRACTORS[args.features]

    print(f"\nanalyse.py v{VERSION}  [Feature-Set: {args.features}]")
    if args.scene:   print(f"  Szenenfilter:  {args.scene}")
    if args.puzzle:  print(f"  Puzzlefilter:  {args.puzzle}")
    print()

    # ── A) Laden ──────────────────────────────────────────────────────────────
    print("A) Logs laden...")
    rows, load_stats = load_logs(args.log_dir)
    print(f"   {load_stats['files']} Datei(en) | "
          f"{load_stats['total_lines']} Zeilen | "
          f"{load_stats['parse_errors']} Parse-Fehler")

    # ── B) Validieren ─────────────────────────────────────────────────────────
    print("\nB) Validierung...")
    valid_rows, val_stats = validate_rows(rows)
    print(f"   Gültig: {val_stats['valid']} | Unvollständig: {val_stats['incomplete']}")

    # ── C) Sequenzen aufbauen ─────────────────────────────────────────────────
    print("\nC) Attempt-Sequenzen aufbauen...")
    attempts = build_attempt_sequences(
        valid_rows, extractor,
        filter_scene=args.scene,
        filter_puzzle=args.puzzle,
    )
    print(f"   {len(attempts)} Attempt(s) rekonstruiert")
    if not attempts:
        print("   Keine Attempts mit semantischen Zuständen gefunden – Abbruch.")
        sys.exit(0)

    # ── D) State Graph ────────────────────────────────────────────────────────
    print("\nD) State Graph aufbauen...")
    nodes, edges = build_state_graph(attempts)
    print(f"   {len(nodes)} Zustände | {len(edges)} Übergänge")

    # ── F+G) Metriken ─────────────────────────────────────────────────────────
    print("\nF–G) Knoten- und Kanten-Metriken berechnen...")
    compute_node_metrics(nodes, attempts)
    compute_edge_metrics(edges)

    # ── I) Loops + Dead Ends ──────────────────────────────────────────────────
    print("\nI) Loops und Dead Ends erkennen...")
    loops     = detect_loops(attempts)
    dead_ends = detect_dead_ends(nodes)
    print(f"   {len(loops)} revisited States | {len(dead_ends)} Dead-End-Kandidaten")

    # ── J) Aha-Momente ────────────────────────────────────────────────────────
    print("\nJ) Aha-Zustände schätzen...")
    aha_states = detect_aha_states(nodes, attempts, args.aha_threshold)
    print(f"   {len(aha_states)} Aha-Kandidaten")

    # ── H) Kohorten-Vergleich ─────────────────────────────────────────────────
    print("\nH) Solver vs. Abbrecher vergleichen...")
    cohort_data = compare_cohorts(attempts, nodes)
    for outcome in ("solved", "abandoned", "failed", "unknown"):
        d = cohort_data.get(outcome, {})
        if d.get("count", 0) > 0:
            print(f"   {outcome:<10} {d['count']} Attempts")

    # ── Zusammenfassung ───────────────────────────────────────────────────────
    cohorts = classify_outcomes(attempts)
    summary = {
        "version":       VERSION,
        "feature_set":   args.features,
        "scene_filter":  args.scene,
        "puzzle_filter": args.puzzle,
        "n_sessions":    len({a["session_id"] for a in attempts}),
        "n_attempts":    len(attempts),
        "n_states":      len(nodes),
        "n_transitions": len(edges),
        "n_solved":      len(cohorts.get("solved",    [])),
        "n_abandoned":   len(cohorts.get("abandoned", [])),
        "n_failed":      len(cohorts.get("failed",    [])),
        "n_unknown":     len(cohorts.get("unknown",   [])),
    }
    _print_summary(summary, loops, dead_ends, aha_states)

    # ── L) Export ─────────────────────────────────────────────────────────────
    print("\nL) Export...")
    export_nodes_edges(nodes, edges, args.out_dir)
    export_trajectories(attempts, args.out_dir)
    export_summary(summary, args.out_dir, cohort_data, loops, dead_ends, aha_states, nodes)
    if args.gexf:
        export_gexf(nodes, edges, args.out_dir)

    # ── K) Playtracer-Visualisierung ──────────────────────────────────────
    if not args.no_viz:
        print("\nK) Playtracer-Visualisierung...")
        save_playtracer(
            nodes, edges, attempts, args.out_dir,
            feature_set=args.features,
            scene_filter=args.scene,
            puzzle_filter=args.puzzle,
        )

    print("\nFertig.")


if __name__ == "__main__":
    main()

# Ausgabesbeispiel:
# python C:\Users\yanni\OneDrive\Desktop\IP2\ip2gd\analyse.py --log-dir "C:\Users\yanni\AppData\Roaming\Godot\app_userdata\BloomOfMemory\analytics" --out-dir "C:\Users\yanni\OneDrive\Desktop\IP2\ip2gd\outputpython"
