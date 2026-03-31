"""
analyze_events.py – Behavioral analytics nach Drachen & Canossa (FDG 2009, CHI Play 2012)

Metriken:
  - Gesamtspieldauer pro Session
  - Zeit pro Szene pro Session
  - Dialog-Anzahl und -Dauer
  - Puzzle-Anzahl und -Dauer
  - Quest-Fortschritt (Funnel)
  - Event-Timeline (visueller Verlauf)

Aufruf:
  python analyze_events.py <analytics_ordner_oder_datei> <output_dir>
"""

import glob
import json
import os
import sys
from collections import defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ── Kurznamen für Szenen-Labels ───────────────────────────────────────────────
SCENE_LABELS = {
    "res://scenes/maps/spaceship.tscn":              "Raumschiff",
    "res://scenes/maps/spaceship_room.tscn":         "Raumschiff-Raum",
    "res://scenes/maps/outside_1.tscn":              "Draußen 1",
    "res://scenes/maps/Outside_2/outside_2.tscn":    "Draußen 2",
    "res://scenes/maps/Outside_3/Outside_3.tscn":    "Draußen 3",
    "res://scenes/maps/Outside_4/Outside_4.tscn":    "Draußen 4",
    "res://scenes/maps/Outside_4/temple.tscn":       "Tempel",
    "res://scenes/maps/Outside_2/sams_cave.tscn":    "Sams Höhle",
    "res://scenes/Menues/main_menu.tscn":            "Hauptmenü",
}

def scene_label(scene):
    return SCENE_LABELS.get(scene, os.path.basename(scene).replace(".tscn", ""))


# ── Laden ─────────────────────────────────────────────────────────────────────

def load_events(path):
    """Lädt alle Zeilen aus einer JSONL-Datei (movement + events)."""
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return rows


def load_all(input_path):
    if os.path.isdir(input_path):
        files = sorted(glob.glob(os.path.join(input_path, "*.jsonl")))
        if not files:
            print(f"Keine .jsonl-Dateien in '{input_path}' gefunden.")
            sys.exit(1)
    else:
        files = [input_path]

    all_rows = []
    for f in files:
        rows = load_events(f)
        print(f"  {os.path.basename(f)}: {len(rows)} Zeilen")
        all_rows.extend(rows)
    return all_rows


# ── Metriken berechnen ────────────────────────────────────────────────────────

def compute_session_metrics(all_rows):
    """
    Gibt ein Dict zurück:
      sessions[session_id] = {
        "duration_ms": int,
        "scene_time": {scene: ms},
        "dialogs": [(dialog, duration_ms), ...],
        "puzzles": [(puzzle?, duration_ms), ...],
        "quests_added": [quest_id, ...],
        "quests_completed": [quest_id, ...],
        "events": [(t_msec, event_type, extra), ...],
      }
    """
    by_session = defaultdict(list)
    for r in all_rows:
        sid = r.get("session_id", "unknown")
        by_session[sid].append(r)

    sessions = {}
    for sid, rows in by_session.items():
        rows.sort(key=lambda r: r.get("t_msec", 0))

        t_start = rows[0].get("t_msec", 0)
        t_end   = rows[-1].get("t_msec", 0)
        duration = t_end - t_start

        scene_time = defaultdict(int)
        current_scene = None
        scene_enter_t = t_start

        dialog_stack = {}   # dialog_name -> t_start
        dialogs = []
        puzzle_stack = {}
        puzzles = []
        quests_added = []
        quests_completed = []
        events_log = []

        for r in rows:
            t = r.get("t_msec", 0)
            rtype = r.get("type", "")
            event = r.get("event", "")

            # Szenenzeit tracken über movement-Zeilen
            if rtype == "movement":
                sc = r.get("scene")
                if sc != current_scene:
                    if current_scene is not None:
                        scene_time[current_scene] += t - scene_enter_t
                    current_scene = sc
                    scene_enter_t = t

            elif rtype == "event":
                events_log.append((t, event, r))

                if event == "scene_changed":
                    to_scene = r.get("to", "")
                    from_scene = r.get("from", "")
                    if current_scene is not None:
                        scene_time[current_scene] += t - scene_enter_t
                    current_scene = to_scene
                    scene_enter_t = t

                elif event == "dialog_started":
                    dlg = r.get("dialog", "dialog")
                    dialog_stack[dlg] = t

                elif event == "dialog_finished":
                    dlg = r.get("dialog", "dialog")
                    started = dialog_stack.pop(dlg, t)
                    dialogs.append((dlg, t - started))

                elif event == "puzzle_started":
                    key = r.get("puzzle_id", r.get("puzzle", "puzzle"))
                    puzzle_stack[key] = t

                elif event == "puzzle_ended":
                    key = r.get("puzzle_id", r.get("puzzle", "puzzle"))
                    started = puzzle_stack.pop(key, t)
                    puzzles.append((key, t - started))

                elif event == "quest_added":
                    quests_added.append(r.get("quest_id", "?"))

                elif event == "quest_completed":
                    quests_completed.append(r.get("quest_id", "?"))

        if current_scene is not None:
            scene_time[current_scene] += t_end - scene_enter_t

        sessions[sid] = {
            "duration_ms": duration,
            "scene_time": dict(scene_time),
            "dialogs": dialogs,
            "puzzles": puzzles,
            "quests_added": quests_added,
            "quests_completed": quests_completed,
            "events": events_log,
            "t_start": t_start,
        }

    return sessions


# ── Plots ─────────────────────────────────────────────────────────────────────

def _ms_to_min(ms):
    return ms / 60000.0


def save_summary_table(sessions, out_path):
    """CSV-Zusammenfassung aller Sessions."""
    lines = ["session_id,dauer_min,szenen_count,dialoge,rätsel,quests_hinzugefügt,quests_abgeschlossen"]
    for sid, m in sorted(sessions.items()):
        lines.append(
            f"{sid},"
            f"{_ms_to_min(m['duration_ms']):.2f},"
            f"{len(m['scene_time'])},"
            f"{len(m['dialogs'])},"
            f"{len(m['puzzles'])},"
            f"{len(m['quests_added'])},"
            f"{len(m['quests_completed'])}"
        )
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"  CSV gespeichert: {out_path}")


def save_scene_time_chart(sessions, out_path):
    """Balkendiagramm: Zeit pro Szene pro Session."""
    all_scenes = sorted({sc for m in sessions.values() for sc in m["scene_time"]})
    if not all_scenes:
        return

    session_ids = sorted(sessions.keys())
    n_sessions = len(session_ids)
    n_scenes = len(all_scenes)

    x = np.arange(n_scenes)
    bar_w = 0.8 / max(n_sessions, 1)

    fig, ax = plt.subplots(figsize=(max(10, n_scenes * 1.2), 6))
    cmap = plt.get_cmap("tab10")

    for i, sid in enumerate(session_ids):
        vals = [_ms_to_min(sessions[sid]["scene_time"].get(sc, 0)) for sc in all_scenes]
        offset = (i - n_sessions / 2 + 0.5) * bar_w
        ax.bar(x + offset, vals, bar_w * 0.9, label=sid[:16], color=cmap(i % 10), alpha=0.85)

    ax.set_xticks(x)
    ax.set_xticklabels([scene_label(s) for s in all_scenes], rotation=30, ha="right")
    ax.set_ylabel("Zeit (Minuten)")
    ax.set_title("Zeit pro Szene – Vergleich aller Sessions")
    ax.legend(fontsize=7, loc="upper right")
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


def save_event_counts_chart(sessions, out_path):
    """Balkendiagramm: Anzahl Dialoge, Rätsel, Quests pro Session."""
    session_ids = sorted(sessions.keys())
    n = len(session_ids)
    x = np.arange(n)
    bar_w = 0.25

    dialogs  = [len(sessions[s]["dialogs"]) for s in session_ids]
    puzzles  = [len(sessions[s]["puzzles"]) for s in session_ids]
    q_done   = [len(sessions[s]["quests_completed"]) for s in session_ids]

    fig, ax = plt.subplots(figsize=(max(7, n * 1.2), 5))
    ax.bar(x - bar_w, dialogs, bar_w, label="Dialoge",  color="#4C8BE8", alpha=0.9)
    ax.bar(x,         puzzles, bar_w, label="Rätsel",   color="#E87C4C", alpha=0.9)
    ax.bar(x + bar_w, q_done,  bar_w, label="Quests ✓", color="#5CB85C", alpha=0.9)

    ax.set_xticks(x)
    ax.set_xticklabels([s[:16] for s in session_ids], rotation=30, ha="right")
    ax.set_ylabel("Anzahl")
    ax.set_title("Events pro Session (Dialoge / Rätsel / Quests abgeschlossen)")
    ax.legend()
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


def save_duration_chart(sessions, out_path):
    """Balkendiagramm: Gesamtspieldauer pro Session."""
    session_ids = sorted(sessions.keys())
    durations = [_ms_to_min(sessions[s]["duration_ms"]) for s in session_ids]

    fig, ax = plt.subplots(figsize=(max(6, len(session_ids) * 1.0), 4))
    colors = plt.get_cmap("tab10")(np.linspace(0, 1, len(session_ids)))
    bars = ax.bar(range(len(session_ids)), durations, color=colors, alpha=0.9)
    ax.set_xticks(range(len(session_ids)))
    ax.set_xticklabels([s[:16] for s in session_ids], rotation=30, ha="right")
    ax.set_ylabel("Minuten")
    ax.set_title("Gesamtspieldauer pro Session")
    ax.grid(axis="y", alpha=0.3)
    for bar, val in zip(bars, durations):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
                f"{val:.1f}m", ha="center", va="bottom", fontsize=8)
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


def save_timeline(sessions, out_path):
    """
    Horizontale Timeline pro Session:
    Szenen als farbige Balken + Event-Marker (Dialog, Puzzle, Quest).
    """
    all_scenes = sorted({sc for m in sessions.values() for sc in m["scene_time"]})
    scene_color = {sc: plt.get_cmap("tab20")(i / max(len(all_scenes), 1))
                   for i, sc in enumerate(all_scenes)}

    session_ids = sorted(sessions.keys())
    n = len(session_ids)
    fig, axes = plt.subplots(n, 1, figsize=(14, max(3, n * 1.8)), squeeze=False)

    for row_i, sid in enumerate(session_ids):
        ax = axes[row_i][0]
        m = sessions[sid]
        t0 = m["t_start"]

        # Szenen-Balken aus scene_changed-Events rekonstruieren
        scene_intervals = []
        current_sc = None
        enter_t = t0
        for (t, event, r) in m["events"]:
            if event == "scene_changed":
                if current_sc is not None:
                    scene_intervals.append((current_sc, enter_t - t0, t - t0))
                current_sc = r.get("to", "")
                enter_t = t
        if current_sc is not None:
            scene_intervals.append((current_sc, enter_t - t0, t0 + m["duration_ms"] - t0))

        # Balken zeichnen
        for (sc, t_rel_start, t_rel_end) in scene_intervals:
            dur = (t_rel_end - t_rel_start) / 1000.0  # → Sekunden
            start_s = t_rel_start / 1000.0
            color = scene_color.get(sc, (0.7, 0.7, 0.7, 1.0))
            ax.barh(0, dur, left=start_s, height=0.6, color=color, alpha=0.85)

        # Event-Marker
        for (t, event, r) in m["events"]:
            t_s = (t - t0) / 1000.0
            if event == "dialog_started":
                ax.axvline(t_s, color="blue",   alpha=0.6, linewidth=1.2, linestyle="--")
            elif event == "puzzle_started":
                ax.axvline(t_s, color="orange", alpha=0.7, linewidth=1.5, linestyle="-.")
            elif event == "quest_completed":
                ax.axvline(t_s, color="green",  alpha=0.8, linewidth=1.5)
            elif event == "quest_added":
                ax.axvline(t_s, color="purple", alpha=0.5, linewidth=1.0, linestyle=":")

        ax.set_yticks([])
        ax.set_ylabel(sid[:16], fontsize=7, rotation=0, labelpad=70, va="center")
        ax.set_xlabel("Zeit (Sekunden)" if row_i == n - 1 else "")
        ax.grid(axis="x", alpha=0.2)

    # Legende für Szenen
    scene_patches = [mpatches.Patch(color=scene_color[sc], label=scene_label(sc))
                     for sc in all_scenes if sc in scene_color]
    event_lines = [
        mpatches.Patch(color="blue",   label="Dialog gestartet"),
        mpatches.Patch(color="orange", label="Rätsel gestartet"),
        mpatches.Patch(color="green",  label="Quest abgeschlossen"),
        mpatches.Patch(color="purple", label="Quest hinzugefügt"),
    ]
    fig.legend(handles=scene_patches + event_lines,
               loc="lower center", ncol=min(6, len(scene_patches) + 4),
               fontsize=7, bbox_to_anchor=(0.5, -0.02))
    fig.suptitle("Event-Timeline pro Session", fontsize=12)
    fig.tight_layout(rect=[0, 0.06, 1, 0.97])
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)


def save_quest_funnel(sessions, out_path):
    """Zeigt wie viele Spieler jeden Quest abgeschlossen haben."""
    quest_counts = defaultdict(int)
    for m in sessions.values():
        for q in m["quests_completed"]:
            quest_counts[q] += 1

    if not quest_counts:
        print("  Kein abgeschlossener Quest gefunden – Funnel übersprungen.")
        return

    quests = sorted(quest_counts.keys(), key=lambda q: quest_counts[q], reverse=True)
    counts = [quest_counts[q] for q in quests]
    n_sessions = len(sessions)

    fig, ax = plt.subplots(figsize=(max(6, len(quests) * 1.2), 4))
    bars = ax.bar(range(len(quests)), counts, color="#5CB85C", alpha=0.85)
    ax.axhline(n_sessions, color="red", linestyle="--", linewidth=1, label=f"Gesamt Sessions ({n_sessions})")
    ax.set_xticks(range(len(quests)))
    ax.set_xticklabels(quests, rotation=30, ha="right")
    ax.set_ylabel("Anzahl Spieler")
    ax.set_title("Quest-Completion-Funnel")
    ax.legend()
    ax.grid(axis="y", alpha=0.3)
    for bar, val in zip(bars, counts):
        pct = val / n_sessions * 100
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.05,
                f"{pct:.0f}%", ha="center", va="bottom", fontsize=8)
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


def save_scene_graph(sessions, out_path):
    """
    Einheitlicher Szenen-Graph nach Drachen & Canossa:
    - Knoten = Szenen
    - Knotengröße = Ø Zeit verbracht (über alle Sessions)
    - Knotenfarbe = Ø Anzahl Events (Dialog + Puzzle + Quest) in dieser Szene
    - Kanten = Szenenübergänge, Dicke = Häufigkeit
    - Annotations = Kennzahlen direkt am Knoten
    """
    # ── Übergänge und Zeit pro Szene sammeln ──────────────────────────────────
    transitions = defaultdict(int)   # (from, to) -> count
    scene_time_total = defaultdict(float)   # scene -> summe ms über alle sessions
    scene_visits = defaultdict(int)         # scene -> anzahl sessions die es besucht haben
    scene_events = defaultdict(int)         # scene -> summe events

    for m in sessions.values():
        # Szenenzeit
        for sc, ms in m["scene_time"].items():
            scene_time_total[sc] += ms
            scene_visits[sc] += 1

        # Übergänge aus Events rekonstruieren
        prev_scene = None
        for (t, event, r) in m["events"]:
            if event == "scene_changed":
                frm = r.get("from", "")
                to  = r.get("to", "")
                if frm and to and frm != to:
                    transitions[(frm, to)] += 1
                prev_scene = to

        # Events pro Szene: Dialog/Puzzle/Quest mit aktueller Szene verknüpfen
        # Wir nutzen die scene_changed-Events als Zeitrahmen
        scene_intervals = []
        current_sc = None
        enter_t = m["t_start"]
        for (t, event, r) in m["events"]:
            if event == "scene_changed":
                if current_sc is not None:
                    scene_intervals.append((current_sc, enter_t, t))
                current_sc = r.get("to", "")
                enter_t = t
        if current_sc is not None:
            scene_intervals.append((current_sc, enter_t, m["t_start"] + m["duration_ms"]))

        for (t, event, r) in m["events"]:
            if event in ("dialog_started", "puzzle_started", "quest_completed"):
                for (sc, t0, t1) in scene_intervals:
                    if t0 <= t <= t1:
                        scene_events[sc] += 1
                        break

    if not scene_time_total:
        print("  Kein Szenen-Graph möglich – keine scene_time-Daten.")
        return

    n_sessions = max(len(sessions), 1)
    all_scenes = list(scene_time_total.keys())

    # ── Layout: Kreisanordnung ─────────────────────────────────────────────────
    n = len(all_scenes)
    angles = [2 * np.pi * i / n for i in range(n)]
    pos = {sc: (np.cos(a), np.sin(a)) for sc, a in zip(all_scenes, angles)}

    # ── Knotengrößen und -farben ───────────────────────────────────────────────
    avg_time_min = {sc: _ms_to_min(scene_time_total[sc]) / n_sessions for sc in all_scenes}
    avg_events   = {sc: scene_events.get(sc, 0) / n_sessions for sc in all_scenes}

    max_time = max(avg_time_min.values()) or 1.0
    max_ev   = max(avg_events.values()) or 1.0

    node_sizes  = [300 + 2500 * (avg_time_min[sc] / max_time) for sc in all_scenes]
    node_colors = [avg_events[sc] / max_ev for sc in all_scenes]  # 0..1 für colormap

    # ── Plot ──────────────────────────────────────────────────────────────────
    fig, ax = plt.subplots(figsize=(12, 12))
    ax.set_aspect("equal")
    ax.axis("off")

    # Kanten zeichnen
    max_trans = max(transitions.values()) if transitions else 1
    for (frm, to), count in transitions.items():
        if frm not in pos or to not in pos:
            continue
        x0, y0 = pos[frm]
        x1, y1 = pos[to]
        lw = 0.5 + 4.5 * (count / max_trans)
        alpha = 0.3 + 0.5 * (count / max_trans)
        ax.annotate(
            "",
            xy=(x1, y1), xytext=(x0, y0),
            arrowprops=dict(arrowstyle="-|>", color="gray",
                            lw=lw, alpha=alpha,
                            connectionstyle="arc3,rad=0.15"),
        )
        # Häufigkeit an der Kante
        mx, my = (x0 + x1) / 2, (y0 + y1) / 2
        ax.text(mx, my, str(count), fontsize=6, color="gray",
                ha="center", va="center", alpha=0.7)

    # Knoten zeichnen
    cmap = plt.get_cmap("YlOrRd")
    xs = [pos[sc][0] for sc in all_scenes]
    ys = [pos[sc][1] for sc in all_scenes]
    scatter = ax.scatter(xs, ys, s=node_sizes, c=node_colors, cmap=cmap,
                         vmin=0, vmax=1, zorder=5, edgecolors="black", linewidths=0.8)

    # Labels + Kennzahlen an jedem Knoten
    for sc in all_scenes:
        x, y = pos[sc]
        label = scene_label(sc)
        t_str = f"{avg_time_min[sc]:.1f} min"
        e_str = f"{avg_events[sc]:.1f} events"
        ax.text(x, y + 0.13, label,  fontsize=8,  ha="center", va="bottom",
                fontweight="bold", zorder=6)
        ax.text(x, y - 0.13, f"{t_str}\n{e_str}", fontsize=6.5, ha="center",
                va="top", color="#333333", zorder=6)

    # Colorbar
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(0, max_ev))
    sm.set_array([])
    cbar = fig.colorbar(sm, ax=ax, fraction=0.03, pad=0.02)
    cbar.set_label("Ø Events pro Session (Dialog / Rätsel / Quest)", fontsize=9)

    # Legende Knotengröße
    for t_val in [0.25, 0.5, 1.0]:
        size = 300 + 2500 * t_val
        ax.scatter([], [], s=size, c="lightgray", edgecolors="black",
                   linewidths=0.8,
                   label=f"Ø {max_time * t_val:.1f} min")
    ax.legend(title="Ø Zeit in Szene", loc="lower left", fontsize=7,
              title_fontsize=8, framealpha=0.8)

    ax.set_title(
        "Szenen-Graph (Drachen & Canossa)\n"
        "Knotengröße = Ø Zeit · Knotenfarbe = Ø Events · Kante = Übergangs-Häufigkeit",
        fontsize=11,
    )
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


def save_puzzle_duration_chart(sessions, out_path):
    """Durchschnittliche Rätsel-Dauer pro Session."""
    session_ids = sorted(sessions.keys())
    avgs = []
    for sid in session_ids:
        durations = [d for _, d in sessions[sid]["puzzles"]]
        avgs.append(np.mean(durations) / 1000.0 if durations else 0.0)  # → Sekunden

    if all(v == 0 for v in avgs):
        print("  Keine Rätsel-Daten – Puzzle-Chart übersprungen.")
        return

    fig, ax = plt.subplots(figsize=(max(6, len(session_ids) * 1.0), 4))
    colors = plt.get_cmap("tab10")(np.linspace(0, 1, len(session_ids)))
    bars = ax.bar(range(len(session_ids)), avgs, color=colors, alpha=0.9)
    ax.set_xticks(range(len(session_ids)))
    ax.set_xticklabels([s[:16] for s in session_ids], rotation=30, ha="right")
    ax.set_ylabel("Ø Dauer (Sekunden)")
    ax.set_title("Durchschnittliche Rätsel-Dauer pro Session")
    ax.grid(axis="y", alpha=0.3)
    for bar, val in zip(bars, avgs):
        if val > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                    f"{val:.1f}s", ha="center", va="bottom", fontsize=8)
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 3:
        print("Usage: python analyze_events.py <analytics.jsonl|ordner> <output_dir>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_dir = sys.argv[2]
    os.makedirs(output_dir, exist_ok=True)

    print("Lade Daten...")
    all_rows = load_all(input_path)
    print(f"  Gesamt: {len(all_rows)} Zeilen\n")

    print("Berechne Metriken...")
    sessions = compute_session_metrics(all_rows)
    print(f"  {len(sessions)} Sessions gefunden\n")

    # Konsolen-Zusammenfassung
    for sid, m in sorted(sessions.items()):
        print(f"  Session: {sid}")
        print(f"    Spieldauer:          {_ms_to_min(m['duration_ms']):.1f} min")
        print(f"    Szenen besucht:      {len(m['scene_time'])}")
        print(f"    Dialoge:             {len(m['dialogs'])}")
        print(f"    Rätsel:              {len(m['puzzles'])}")
        print(f"    Quests hinzugefügt:  {len(m['quests_added'])}")
        print(f"    Quests abgeschlossen:{len(m['quests_completed'])}")
        if m["scene_time"]:
            top_scene = max(m["scene_time"], key=m["scene_time"].get)
            print(f"    Meiste Zeit in:      {scene_label(top_scene)} "
                  f"({_ms_to_min(m['scene_time'][top_scene]):.1f} min)")
        print()

    print("Speichere Diagramme...")
    save_summary_table(sessions,         os.path.join(output_dir, "sessions_summary.csv"))
    save_scene_graph(sessions,           os.path.join(output_dir, "scene_graph.png"))
    save_duration_chart(sessions,        os.path.join(output_dir, "duration.png"))
    save_scene_time_chart(sessions,      os.path.join(output_dir, "scene_time.png"))
    save_event_counts_chart(sessions,    os.path.join(output_dir, "event_counts.png"))
    save_timeline(sessions,              os.path.join(output_dir, "timeline.png"))
    save_quest_funnel(sessions,          os.path.join(output_dir, "quest_funnel.png"))
    save_puzzle_duration_chart(sessions, os.path.join(output_dir, "puzzle_duration.png"))
    print("Fertig.")


if __name__ == "__main__":
    main()
