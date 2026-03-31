"""
analyze.py  –  Bewegungsanalyse + Feature-basierter Playtracer
               nach Liu et al. (FDG 2011) & Drachen & Canossa (FDG 2009)

Teil 1 – Bewegung (pro Szene):
  • Tracks-Overlay       (*_tracks.png)
  • Heatmap              (*_heatmap.png)
  • Flow-Pfeile          (*_flow.png)

Teil 2 – Feature-basierter Playtracer (pro Szene):
  • Ein Playtracer-Graph pro Szene
  • Gelb  = Eintrittszustand  (State beim Betreten der Szene)
  • Grün  = Austrittszustand  (State beim Verlassen der Szene)
  • Orange= Eintritt & Austritt gleicher Zustand
  • Knoten-Größe  ∝  Anzahl Sessions die diesen Zustand besuchten
  • MDS-Layout aus paarweiser Zustandsdistanz (symmetrische Differenz der Features)
  • Ausgabe: playtracer_<szene>.png

Aufruf:
  python analyze.py <analytics_ordner_oder_datei> <output_dir>
"""

import glob
import json
import math
import os
import sys
import warnings
from collections import defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from PIL import Image, ImageDraw

try:
    from sklearn.manifold import MDS
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False
    print("Hinweis: scikit-learn nicht installiert – Playtracer wird übersprungen.")
    print("  pip install scikit-learn")

# ── Konstanten ────────────────────────────────────────────────────────────────
GRID_W        = 256
GRID_H        = 256
IMG_W         = 1024
IMG_H         = 1024
ARROW_STEP    = 16
MIN_SEG_LEN   = 0.5

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

SCENE_MAPS = {
    "res://scenes/maps/spaceship.tscn":              os.path.join(_SCRIPT_DIR, "wiki", "Oris_Spaceship.png"),
    "res://scenes/maps/outside_1.tscn":              os.path.join(_SCRIPT_DIR, "wiki", "Outside_1.png"),
    "res://scenes/maps/Outside_2/outside_2.tscn":    os.path.join(_SCRIPT_DIR, "wiki", "Outside_2.png"),
    "res://scenes/maps/Outside_3/Outside_3.tscn":    os.path.join(_SCRIPT_DIR, "wiki", "Outside_3.png"),
    "res://scenes/maps/Outside_4/Outside_4.tscn":    os.path.join(_SCRIPT_DIR, "wiki", "Outside_4.png"),
    "res://scenes/maps/Outside_4/temple.tscn":       os.path.join(_SCRIPT_DIR, "wiki", "Temple.png"),
    "res://scenes/maps/Outside_2/sams_cave.tscn":    os.path.join(_SCRIPT_DIR, "wiki", "Sams_Cave1.png"),
}

SCENE_LABELS = {
    "res://scenes/maps/spaceship.tscn":           "Raumschiff",
    "res://scenes/maps/spaceship_room.tscn":      "Raumschiff-Raum",
    "res://scenes/maps/outside_1.tscn":           "Draußen 1",
    "res://scenes/maps/Outside_2/outside_2.tscn": "Draußen 2",
    "res://scenes/maps/Outside_3/Outside_3.tscn": "Draußen 3",
    "res://scenes/maps/Outside_4/Outside_4.tscn": "Draußen 4",
    "res://scenes/maps/Outside_4/temple.tscn":    "Tempel",
    "res://scenes/maps/Outside_2/sams_cave.tscn": "Sams Höhle",
}


# ══════════════════════════════════════════════════════════════════════════════
# LADEN
# ══════════════════════════════════════════════════════════════════════════════

def load_all(input_path):
    """Lädt alle JSONL-Zeilen aus einer Datei oder einem Ordner."""
    if os.path.isdir(input_path):
        files = sorted(glob.glob(os.path.join(input_path, "*.jsonl")))
        if not files:
            print(f"Keine .jsonl-Dateien in '{input_path}'.")
            sys.exit(1)
    else:
        files = [input_path]

    all_rows = []
    for f in files:
        count = 0
        with open(f, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    all_rows.append(json.loads(line))
                    count += 1
                except json.JSONDecodeError:
                    continue
        print(f"  {os.path.basename(f)}: {count} Zeilen")
    return all_rows


def load_map_bounds(input_path):
    search_dir = input_path if os.path.isdir(input_path) else os.path.dirname(os.path.abspath(input_path))
    bounds_path = os.path.join(search_dir, "map_bounds.json")
    if not os.path.exists(bounds_path):
        return {}
    with open(bounds_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if "scene" in data and "limit_left" in data:
        scene = data["scene"]
        return {scene: {k: data[k] for k in ("limit_left", "limit_right", "limit_top", "limit_bottom")}}
    return data


# ══════════════════════════════════════════════════════════════════════════════
# TEIL 1 – BEWEGUNGSVISUALISIERUNG
# ══════════════════════════════════════════════════════════════════════════════

def movement_rows(all_rows):
    return [r for r in all_rows if r.get("type") == "movement" and "x" in r and "y" in r]


def group_by_scene(rows):
    grouped = defaultdict(list)
    for r in rows:
        grouped[r.get("scene", "unknown")].append(r)
    for sc in grouped:
        grouped[sc].sort(key=lambda r: (r.get("session_id", ""), r.get("t_msec", 0)))
    return grouped


def compute_bounds(rows, padding=16.0):
    xs = [r["x"] for r in rows]
    ys = [r["y"] for r in rows]
    min_x, max_x = min(xs) - padding, max(xs) + padding
    min_y, max_y = min(ys) - padding, max(ys) + padding
    if abs(max_x - min_x) < 1e-6: max_x += 1.0
    if abs(max_y - min_y) < 1e-6: max_y += 1.0
    return min_x, min_y, max_x, max_y


def get_scene_config(scene, rows, map_bounds):
    if map_bounds and scene in map_bounds:
        b = map_bounds[scene]
        bounds = (b["limit_left"], b["limit_top"], b["limit_right"], b["limit_bottom"])
    else:
        bounds = compute_bounds(rows)
    image = SCENE_MAPS.get(scene)
    return image, bounds


def world_to_uv(x, y, bounds):
    min_x, min_y, max_x, max_y = bounds
    return (x - min_x) / (max_x - min_x), (y - min_y) / (max_y - min_y)


def uv_to_img(u, v, w, h):
    return (int(max(0, min(w - 1, round(u * (w - 1))))),
            int(max(0, min(h - 1, round(v * (h - 1))))))


def make_base(map_path):
    if map_path and os.path.exists(map_path):
        return Image.open(map_path).convert("RGBA").resize((IMG_W, IMG_H))
    return Image.new("RGBA", (IMG_W, IMG_H), (0, 0, 0, 255))


def save_tracks(rows, bounds, map_path, out_path):
    base    = make_base(map_path)
    overlay = Image.new("RGBA", (IMG_W, IMG_H), (0, 0, 0, 0))
    draw    = ImageDraw.Draw(overlay, "RGBA")

    by_session = defaultdict(list)
    for r in rows:
        by_session[r.get("session_id", "x")].append(r)

    for _, samples in by_session.items():
        samples.sort(key=lambda r: r.get("t_msec", 0))
        for a, b in zip(samples[:-1], samples[1:]):
            if a.get("scene") != b.get("scene"):
                continue
            if math.dist((a["x"], a["y"]), (b["x"], b["y"])) < MIN_SEG_LEN:
                continue
            ua, va = world_to_uv(a["x"], a["y"], bounds)
            ub, vb = world_to_uv(b["x"], b["y"], bounds)
            x0, y0 = uv_to_img(ua, va, IMG_W, IMG_H)
            x1, y1 = uv_to_img(ub, vb, IMG_W, IMG_H)
            draw.line((x0, y0, x1, y1), fill=(255, 50, 50, 180), width=4)

    Image.alpha_composite(base, overlay).save(out_path)


def blur3x3(arr):
    padded = np.pad(arr, ((1, 1), (1, 1)), mode="edge")
    out    = np.zeros_like(arr)
    k      = np.array([[1, 2, 1], [2, 4, 2], [1, 2, 1]], dtype=np.float32) / 16.0
    for y in range(arr.shape[0]):
        for x in range(arr.shape[1]):
            out[y, x] = np.sum(padded[y:y+3, x:x+3] * k)
    return out


def rasterize(rows, bounds):
    density = np.zeros((GRID_H, GRID_W), dtype=np.float32)
    vx      = np.zeros_like(density)
    vy      = np.zeros_like(density)

    by_session = defaultdict(list)
    for r in rows:
        by_session[r.get("session_id", "x")].append(r)

    for _, samples in by_session.items():
        samples.sort(key=lambda r: r.get("t_msec", 0))
        for a, b in zip(samples[:-1], samples[1:]):
            if a.get("scene") != b.get("scene"):
                continue
            dx  = b["x"] - a["x"]
            dy  = b["y"] - a["y"]
            seg = math.hypot(dx, dy)
            if seg < MIN_SEG_LEN:
                continue
            dir_x, dir_y = dx / seg, dy / seg
            ua, va = world_to_uv(a["x"], a["y"], bounds)
            ub, vb = world_to_uv(b["x"], b["y"], bounds)
            steps = max(1, int(math.ceil(math.hypot(ub - ua, vb - va) * max(GRID_W, GRID_H))))
            for i in range(steps + 1):
                t  = i / steps
                u  = ua + (ub - ua) * t
                v  = va + (vb - va) * t
                gx = max(0, min(GRID_W - 1, int(u * (GRID_W - 1))))
                gy = max(0, min(GRID_H - 1, int(v * (GRID_H - 1))))
                density[gy, gx] += 1.0
                vx[gy, gx]      += dir_x
                vy[gy, gx]      += dir_y
    return density, vx, vy


def save_heatmap(density, map_path, out_path):
    base = make_base(map_path)
    d    = blur3x3(density)
    if d.max() > 0:
        d = d / d.max()
    d  = np.power(d, 0.5)
    heat = Image.new("RGBA", (GRID_W, GRID_H))
    px   = heat.load()
    for y in range(GRID_H):
        for x in range(GRID_W):
            v = float(d[y, x])
            r = int(min(255, 255 * min(1.0, v * 2.0)))
            g = int(min(255, 255 * max(0.0, (v - 0.25) / 0.75)))
            b = int(min(255, 255 * max(0.0, (v - 0.65) / 0.35)))
            px[x, y] = (r, g, b, int(210 * v))
    heat = heat.resize((IMG_W, IMG_H), Image.Resampling.NEAREST)
    Image.alpha_composite(base, heat).save(out_path)


def save_flow(density, vx, vy, map_path, out_path):
    base    = make_base(map_path)
    overlay = Image.new("RGBA", (IMG_W, IMG_H), (0, 0, 0, 0))
    draw    = ImageDraw.Draw(overlay, "RGBA")
    ds = blur3x3(density)
    xs = blur3x3(vx)
    ys = blur3x3(vy)

    for gy in range(0, GRID_H, ARROW_STEP):
        for gx in range(0, GRID_W, ARROW_STEP):
            d = ds[gy, gx]
            if d < 1.0:
                continue
            sx, sy = xs[gy, gx], ys[gy, gx]
            mag    = math.hypot(sx, sy)
            if mag < 0.001:
                continue
            dx, dy = sx / mag, sy / mag
            conf   = min(1.0, mag / max(d, 1e-5))
            if conf < 0.15:
                continue
            x  = int(gx / (GRID_W - 1) * (IMG_W - 1))
            y  = int(gy / (GRID_H - 1) * (IMG_H - 1))
            x2 = x + dx * (10 + 18 * conf)
            y2 = y + dy * (10 + 18 * conf)
            draw.line((x, y, x2, y2), fill=(0, 255, 255, int(80 + 175 * conf)), width=2)

    Image.alpha_composite(base, overlay).save(out_path)


# ══════════════════════════════════════════════════════════════════════════════
# TEIL 2 – FEATURE-BASIERTER PLAYTRACER (Liu et al. FDG 2011)
#
# State-Feature = frozenset der bisher abgeschlossenen Quests + laufenden Rätsel
# Gleiche Feature-Kombination → gleicher Knoten (State-Kollaps wie im Paper)
# Distanz(A, B) = |A △ B|  (symmetrische Differenz der Feature-Mengen)
# Layout via MDS (Classical Multidimensional Scaling)
# ══════════════════════════════════════════════════════════════════════════════

def _extract_semantic_state(row):
    """
    Extrahiert einen frozenset-Zustand aus einer type:"semantic"-Zeile.
    Das state-Objekt ist unter row["state"] verschachtelt.
    """
    s = row.get("state", {})
    features = set()

    # Abgeschlossene Quests
    for q in s.get("completed_quests", []):
        features.add(f"quest:{q}")

    # Boolean-Rätsel-Flags
    for flag in ("stone_puzzle_solved", "color_code_solved", "statue_puzzle_solved",
                 "temple_puzzle_solved", "all_tripods_interacted", "treasure_chest_solved"):
        if s.get(flag):
            features.add(flag)

    # Boolean-Item-Flags
    for flag in ("map_collected", "diary_collected", "shovel_collected"):
        if s.get(flag):
            features.add(flag)

    # Tutorial
    if s.get("tutorial_done"):
        features.add("tutorial_done")

    # NPC-Gesprächsstand (nur wenn > 0)
    stage = s.get("mr_blob_dialog_stage", 0)
    if stage:
        features.add(f"mr_blob:{stage}")

    return frozenset(features)


def _build_per_scene_sequences(all_rows):
    """
    Pro Session+Szene-Besuch eine Zustandsfolge aufbauen.
    Ein "Besuch" beginnt mit scene_changed und endet beim nächsten scene_changed.
    Returns:
      scene_visits: { scene -> [(session_id, [(state, t_msec), ...]), ...] }
      all_quest_ids: set
    """
    by_session = defaultdict(list)
    for r in all_rows:
        by_session[r.get("session_id", "unknown")].append(r)

    scene_visits  = defaultdict(list)  # scene -> [(sid, visit_seq), ...]
    all_quest_ids = set()

    for sid, rows in by_session.items():
        rows.sort(key=lambda r: r.get("t_msec", 0))
        has_semantic = any(r.get("type") == "semantic" for r in rows)
        if not has_semantic:
            continue

        current_scene = None
        current_visit = []       # [(state, t_msec), ...] für aktuellen Besuch
        last_state    = frozenset()

        for r in rows:
            rtype = r.get("type", "")
            t     = r.get("t_msec", 0)

            if rtype == "scene_changed":
                # Aktuellen Besuch abschließen
                if current_scene is not None and current_visit:
                    scene_visits[current_scene].append((sid, current_visit[:]))
                # Neuen Besuch beginnen
                current_scene = r.get("to")
                current_visit = [(last_state, t)]

            elif rtype == "semantic":
                state = _extract_semantic_state(r)
                for q in r.get("state", {}).get("completed_quests", []):
                    all_quest_ids.add(q)
                last_state = state
                if current_scene is not None:
                    if not current_visit or state != current_visit[-1][0]:
                        current_visit.append((state, t))

        # Letzten Besuch abschließen
        if current_scene is not None and current_visit:
            scene_visits[current_scene].append((sid, current_visit[:]))

    return scene_visits, all_quest_ids


def _state_label(state):
    """Erzeugt ein kurzes mehrzeiliges Label für einen Zustand."""
    parts = []
    for f in sorted(state):
        if f.startswith("puzzle:"):
            continue
        elif f.startswith("quest:"):
            parts.append(f[6:])
        elif f.startswith("mr_blob:"):
            parts.append(f"blob:{f[8:]}")
        elif f.endswith("_solved"):
            parts.append(f.replace("_solved", "✓").replace("_", ""))
        elif f.endswith("_collected"):
            parts.append(f.replace("_collected", "").replace("_", ""))
        elif f == "tutorial_done":
            parts.append("tut✓")
        else:
            parts.append(f.replace("puzzle_done:", "✓").replace("_", ""))
    return "\n".join(parts) if parts else "Start"


def _state_distance(a, b):
    """Symmetrische Differenz der Feature-Mengen (wie im Paper)."""
    return len(a.symmetric_difference(b))


def save_playtracer_per_scene(all_rows, output_dir):
    """Erstellt einen Feature-basierten Playtracer pro Szene."""
    if not HAS_SKLEARN:
        return

    scene_visits, all_quests = _build_per_scene_sequences(all_rows)
    if not scene_visits:
        print("  Playtracer: keine Szenen-Daten gefunden.")
        return

    for scene, visits in sorted(scene_visits.items()):
        if not visits:
            continue

        scene_label = SCENE_LABELS.get(scene, scene)

        # ── States + Transitionen pro Szene sammeln ───────────────────────────
        node_visitors = defaultdict(set)  # state -> set(session_ids)
        transitions   = defaultdict(int)  # (state_a, state_b) -> count
        entry_states  = set()             # Zustände beim Szeneneintritt
        exit_states   = set()             # Zustände beim Szenenende

        for sid, visit in visits:
            if not visit:
                continue
            entry_states.add(visit[0][0])
            exit_states.add(visit[-1][0])
            for i, (state, _) in enumerate(visit):
                node_visitors[state].add(sid)
                if i > 0:
                    prev = visit[i - 1][0]
                    if prev != state:
                        transitions[(prev, state)] += 1

        all_states = list(node_visitors.keys())
        n          = len(all_states)
        if n < 2:
            print(f"  Playtracer {scene_label}: nur {n} Zustand – übersprungen.")
            continue

        state_idx = {s: i for i, s in enumerate(all_states)}

        # ── Distanzmatrix ─────────────────────────────────────────────────────
        dist_matrix = np.zeros((n, n), dtype=np.float64)
        for i in range(n):
            for j in range(i + 1, n):
                d = _state_distance(all_states[i], all_states[j])
                dist_matrix[i, j] = d
                dist_matrix[j, i] = d

        # ── MDS-Layout ────────────────────────────────────────────────────────
        n_components = min(2, n - 1)
        with warnings.catch_warnings():
            warnings.filterwarnings("ignore", category=FutureWarning, module="sklearn")
            mds = MDS(
                n_components=n_components,
                metric=True,
                dissimilarity="precomputed",
                random_state=42,
                normalized_stress="auto",
                n_init=4,
                init="random",
            )
            emb = mds.fit_transform(dist_matrix)

        if n_components == 1:
            pos = np.column_stack([emb[:, 0], np.zeros(n)])
        else:
            pos = emb

        max_visitors = max(len(v) for v in node_visitors.values())
        max_trans    = max(transitions.values()) if transitions else 1
        n_visits     = len(visits)

        # ── Plot ──────────────────────────────────────────────────────────────
        fig, ax = plt.subplots(figsize=(11, 10))
        ax.axis("off")
        ax.set_aspect("equal")

        # Kanten
        for (sa, sb), count in transitions.items():
            if sa not in state_idx or sb not in state_idx:
                continue
            ia, ib = state_idx[sa], state_idx[sb]
            lw    = 0.3 + 4.5 * (count / max_trans)
            alpha = 0.15 + 0.55 * (count / max_trans)
            ax.annotate(
                "",
                xy=pos[ib], xytext=pos[ia],
                arrowprops=dict(
                    arrowstyle="-|>",
                    color="#4466aa",
                    lw=lw,
                    alpha=alpha,
                    mutation_scale=8,
                    connectionstyle="arc3,rad=0.12",
                ),
                zorder=2,
            )

        # Knoten
        for i, state in enumerate(all_states):
            n_vis = len(node_visitors[state])
            size  = 40 + 1200 * (n_vis / max_visitors)
            x, y  = pos[i]

            is_entry = state in entry_states
            is_exit  = state in exit_states

            if is_entry and is_exit:
                color, ec, lw, zo = "orange",   "darkorange",  1.5, 6
            elif is_entry:
                color, ec, lw, zo = "yellow",   "goldenrod",   1.5, 6
            elif is_exit:
                color, ec, lw, zo = "#00dd55",  "darkgreen",   1.5, 6
            else:
                gray  = max(0.05, 0.70 - 0.65 * (n_vis / max_visitors))
                color, ec, lw, zo = (gray, gray, gray), "none", 0, 3

            ax.scatter(x, y, s=size, c=[color], edgecolors=ec,
                       linewidths=lw, zorder=zo)
            ax.text(x, y - 0.04, _state_label(state), fontsize=5.5,
                    ha="center", va="top", color="#111111", zorder=7, alpha=0.85)

        # Legende
        handles = [
            mpatches.Patch(facecolor="yellow",  edgecolor="goldenrod",  label="Eintrittszustand (Scene Entry)"),
            mpatches.Patch(facecolor="#00dd55", edgecolor="darkgreen",  label="Austrittszustand (Scene Exit)"),
            mpatches.Patch(facecolor="orange",  edgecolor="darkorange", label="Eintritt & Austritt (kein Fortschritt)"),
            mpatches.Patch(facecolor="#111111", label="Oft besuchter Zustand"),
            mpatches.Patch(facecolor="#aaaaaa", label="Selten besuchter Zustand"),
        ]
        ax.legend(handles=handles, loc="lower right", fontsize=8, framealpha=0.9)

        quest_list = ", ".join(sorted(all_quests)) if all_quests else "–"
        ax.set_title(
            f"Playtracer: {scene_label}  ({n_visits} Besuche · {n} Zustände)\n"
            f"Gelb=Szeneneintritt · Grün=Szenenende · Orange=kein Fortschritt · Größe ∝ Besuche · MDS\n"
            f"Quests: {quest_list}",
            fontsize=9,
        )
        fig.tight_layout()
        safe     = scene.replace("/", "_").replace("\\", "_").replace(":", "_")
        out_path = os.path.join(output_dir, f"playtracer_{safe}.png")
        fig.savefig(out_path, dpi=150)
        plt.close(fig)
        print(f"  Playtracer {scene_label}: {out_path}")


# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════

def main():
    if len(sys.argv) < 3:
        print("Usage: python analyze.py <analytics.jsonl|ordner> <output_dir>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_dir = sys.argv[2]
    os.makedirs(output_dir, exist_ok=True)

    print("Lade Daten...")
    all_rows = load_all(input_path)
    print(f"  Gesamt: {len(all_rows)} Zeilen\n")

    map_bounds = load_map_bounds(input_path)

    # ── Teil 1: Bewegungsvisualisierung ───────────────────────────────────────
    mov_rows = movement_rows(all_rows)
    if mov_rows:
        print("Teil 1 – Bewegungsvisualisierung:")
        grouped = group_by_scene(mov_rows)
        for scene, rows in sorted(grouped.items()):
            safe      = scene.replace("/", "_").replace("\\", "_").replace(":", "_")
            map_path, bounds = get_scene_config(scene, rows, map_bounds)
            label     = SCENE_LABELS.get(scene, safe)

            save_tracks(rows, bounds, map_path, os.path.join(output_dir, f"{safe}_tracks.png"))
            density, vx, vy = rasterize(rows, bounds)
            save_heatmap(density, map_path, os.path.join(output_dir, f"{safe}_heatmap.png"))
            save_flow(density, vx, vy, map_path, os.path.join(output_dir, f"{safe}_flow.png"))
            print(f"  {label}: tracks + heatmap + flow gespeichert")
    else:
        print("Keine Bewegungsdaten gefunden.")

    # ── Teil 2: Feature-basierter Playtracer (pro Szene) ─────────────────────
    print("\nTeil 2 – Playtracer (Feature-basiert, pro Szene):")
    save_playtracer_per_scene(all_rows, output_dir)

    print("\nFertig.")


if __name__ == "__main__":
    main()

# Aufruf:
# python analyze.py
#   "C:\Users\yanni\AppData\Roaming\Godot\app_userdata\BloomOfMemory\analytics"
#   "C:\Users\yanni\OneDrive\Desktop\IP2\ip2gd\outputpython"
