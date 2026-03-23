import base64, struct, re

def decode_tilemap(b64_data):
    raw = base64.b64decode(b64_data)
    cells = []
    cell_size = 12
    for i in range(0, len(raw) - cell_size + 1, cell_size):
        x = struct.unpack_from('<h', raw, i)[0]
        y = struct.unpack_from('<h', raw, i + 2)[0]
        cells.append((x, y))
    return cells

for scene_name, scene_path in [
    ("spaceship", r"c:\Users\yanni\OneDrive\Desktop\IP2\ip2gd\scenes\maps\spaceship.tscn"),
    ("outside_1", r"c:\Users\yanni\OneDrive\Desktop\IP2\ip2gd\scenes\maps\outside_1.tscn"),
]:
    with open(scene_path, encoding="utf-8") as f:
        content = f.read()
    matches = re.findall(r'tile_map_data = PackedByteArray\("([^"]+)"\)', content)
    all_cells = []
    for m in matches:
        all_cells += decode_tilemap(m)
    if not all_cells:
        print(f"{scene_name}: keine Tilemap-Daten gefunden")
        continue
    xs = [c[0] for c in all_cells]
    ys = [c[1] for c in all_cells]
    ts = 16
    wx_min, wx_max = min(xs) * ts, max(xs) * ts + ts
    wy_min, wy_max = min(ys) * ts, max(ys) * ts + ts
    print(f"{scene_name}:")
    print(f"  Tile-Coords: x [{min(xs)}, {max(xs)}], y [{min(ys)}, {max(ys)}]")
    print(f"  World-Bounds: x [{wx_min}, {wx_max}], y [{wy_min}, {wy_max}]")
