import json
import math
import os
import sys
from collections import defaultdict

import numpy as np
from PIL import Image, ImageDraw

# Nutzung:
# python analyze_movement.py path/to/movement_xxx.jsonl output_dir

GRID_W = 256
GRID_H = 256
IMG_W = 1024
IMG_H = 1024
ARROW_STEP = 16
MIN_SEGMENT_LEN = 0.5


def load_rows(path):
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                pass
    return rows


def group_by_scene(rows):
    grouped = defaultdict(list)
    for r in rows:
        scene = r.get("scene", "unknown_scene")
        grouped[scene].append(r)
    for scene in grouped:
        grouped[scene].sort(key=lambda x: (x.get("session_id", ""), x.get("t_msec", 0)))
    return grouped


def compute_bounds(rows, padding=16.0):
    xs = [r["x"] for r in rows]
    ys = [r["y"] for r in rows]
    min_x = min(xs) - padding
    max_x = max(xs) + padding
    min_y = min(ys) - padding
    max_y = max(ys) + padding
    if abs(max_x - min_x) < 1e-6:
        max_x += 1.0
    if abs(max_y - min_y) < 1e-6:
        max_y += 1.0
    return min_x, min_y, max_x, max_y


def world_to_uv(x, y, bounds):
    min_x, min_y, max_x, max_y = bounds
    u = (x - min_x) / (max_x - min_x)
    v = (y - min_y) / (max_y - min_y)
    return u, v


def uv_to_img(u, v, w, h):
    px = int(max(0, min(w - 1, round(u * (w - 1)))))
    py = int(max(0, min(h - 1, round(v * (h - 1)))))
    return px, py


def draw_tracks(rows, bounds, out_path):
    img = Image.new("RGBA", (IMG_W, IMG_H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img, "RGBA")

    by_session = defaultdict(list)
    for r in rows:
        by_session[r.get("session_id", "default")].append(r)

    for _, samples in by_session.items():
        samples.sort(key=lambda x: x.get("t_msec", 0))
        for a, b in zip(samples[:-1], samples[1:]):
            ax, ay = a["x"], a["y"]
            bx, by = b["x"], b["y"]

            # Nur innerhalb derselben Szene und Session verbinden
            if a.get("scene") != b.get("scene"):
                continue

            if math.dist((ax, ay), (bx, by)) < MIN_SEGMENT_LEN:
                continue

            ua, va = world_to_uv(ax, ay, bounds)
            ub, vb = world_to_uv(bx, by, bounds)

            x0, y0 = uv_to_img(ua, va, IMG_W, IMG_H)
            x1, y1 = uv_to_img(ub, vb, IMG_W, IMG_H)

            draw.line((x0, y0, x1, y1), fill=(255, 255, 255, 50), width=2)

    img.save(out_path)


def rasterize(rows, bounds):
    density = np.zeros((GRID_H, GRID_W), dtype=np.float32)
    vx = np.zeros((GRID_H, GRID_W), dtype=np.float32)
    vy = np.zeros((GRID_H, GRID_W), dtype=np.float32)

    by_session = defaultdict(list)
    for r in rows:
        by_session[r.get("session_id", "default")].append(r)

    for _, samples in by_session.items():
        samples.sort(key=lambda x: x.get("t_msec", 0))

        for a, b in zip(samples[:-1], samples[1:]):
            if a.get("scene") != b.get("scene"):
                continue

            ax, ay = a["x"], a["y"]
            bx, by = b["x"], b["y"]

            dx = bx - ax
            dy = by - ay
            seg_len = math.hypot(dx, dy)
            if seg_len < MIN_SEGMENT_LEN:
                continue

            dir_x = dx / seg_len
            dir_y = dy / seg_len

            ua, va = world_to_uv(ax, ay, bounds)
            ub, vb = world_to_uv(bx, by, bounds)

            du = ub - ua
            dv = vb - va

            steps = max(1, int(math.ceil(math.hypot(du, dv) * max(GRID_W, GRID_H))))
            for i in range(steps + 1):
                t = i / steps
                u = ua + du * t
                v = va + dv * t

                gx = max(0, min(GRID_W - 1, int(u * (GRID_W - 1))))
                gy = max(0, min(GRID_H - 1, int(v * (GRID_H - 1))))

                density[gy, gx] += 1.0
                vx[gy, gx] += dir_x
                vy[gy, gx] += dir_y

    return density, vx, vy


def blur3x3(arr):
    padded = np.pad(arr, ((1, 1), (1, 1)), mode="edge")
    out = np.zeros_like(arr)
    kernel = np.array([
        [1, 2, 1],
        [2, 4, 2],
        [1, 2, 1]
    ], dtype=np.float32)
    kernel /= kernel.sum()

    for y in range(arr.shape[0]):
        for x in range(arr.shape[1]):
            patch = padded[y:y+3, x:x+3]
            out[y, x] = np.sum(patch * kernel)
    return out


def save_heatmap(density, out_path):
    d = blur3x3(density)
    if d.max() > 0:
        d = d / d.max()

    # Gamma, damit schwächere Bereiche sichtbarer werden
    d = np.power(d, 0.5)

    img = Image.new("RGBA", (GRID_W, GRID_H))
    px = img.load()

    for y in range(GRID_H):
        for x in range(GRID_W):
            v = float(d[y, x])
            # Schwarz -> Rot -> Gelb -> Weiß
            r = int(min(255, 255 * min(1.0, v * 1.8)))
            g = int(min(255, 255 * max(0.0, (v - 0.35) / 0.65)))
            b = int(min(255, 255 * max(0.0, (v - 0.75) / 0.25)))
            a = int(255 * v)
            px[x, y] = (r, g, b, a)

    img = img.resize((IMG_W, IMG_H), Image.Resampling.NEAREST)
    img.save(out_path)


def save_flow_arrows(density, vx, vy, out_path):
    img = Image.new("RGBA", (IMG_W, IMG_H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img, "RGBA")

    density_s = blur3x3(density)
    vx_s = blur3x3(vx)
    vy_s = blur3x3(vy)

    for gy in range(0, GRID_H, ARROW_STEP):
        for gx in range(0, GRID_W, ARROW_STEP):
            d = density_s[gy, gx]
            if d < 1.0:
                continue

            sx = vx_s[gy, gx]
            sy = vy_s[gy, gx]
            mag = math.hypot(sx, sy)
            if mag < 0.001:
                continue

            dx = sx / mag
            dy = sy / mag

            confidence = min(1.0, mag / max(d, 1e-5))
            if confidence < 0.15:
                continue

            x = int(gx / (GRID_W - 1) * (IMG_W - 1))
            y = int(gy / (GRID_H - 1) * (IMG_H - 1))

            length = 10 + 18 * confidence
            x2 = x + dx * length
            y2 = y + dy * length

            alpha = int(80 + 175 * confidence)
            draw.line((x, y, x2, y2), fill=(255, 255, 255, alpha), width=2)

            # kleine Pfeilspitze
            ang = math.atan2(dy, dx)
            left = ang + math.radians(150)
            right = ang - math.radians(150)
            hl = 6
            lx = x2 + math.cos(left) * hl
            ly = y2 + math.sin(left) * hl
            rx = x2 + math.cos(right) * hl
            ry = y2 + math.sin(right) * hl
            draw.line((x2, y2, lx, ly), fill=(255, 255, 255, alpha), width=2)
            draw.line((x2, y2, rx, ry), fill=(255, 255, 255, alpha), width=2)

    img.save(out_path)


def main():
    if len(sys.argv) < 3:
        print("Usage: python analyze_movement.py movement.jsonl output_dir")
        sys.exit(1)

    input_path = sys.argv[1]
    output_dir = sys.argv[2]
    os.makedirs(output_dir, exist_ok=True)

    rows = load_rows(input_path)
    if not rows:
        print("Keine Daten gefunden.")
        sys.exit(1)

    grouped = group_by_scene(rows)

    for scene, scene_rows in grouped.items():
        safe_scene = scene.replace("/", "_").replace("\\", "_").replace(":", "_")
        bounds = compute_bounds(scene_rows)

        draw_tracks(scene_rows, bounds, os.path.join(output_dir, f"{safe_scene}_tracks.png"))

        density, vx, vy = rasterize(scene_rows, bounds)
        save_heatmap(density, os.path.join(output_dir, f"{safe_scene}_heatmap.png"))
        save_flow_arrows(density, vx, vy, os.path.join(output_dir, f"{safe_scene}_flow.png"))

        print(f"Fertig: {scene}")

if __name__ == "__main__":
    main()