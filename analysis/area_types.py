"""Raeumliche Generalisierung: Szenenpfad -> semantischer Bereichstyp.

Ordnet die konkreten Godot-Szenen von "Bloom Of Memory" den in Kapitel 3.2.1
beschriebenen Bereichstypen zu (Innenbereich, Aussen-/Erkundungsbereich,
Raetselbereich, narrativer Bereich).

Die Telemetrie speichert Szenen teils als res://-Pfad (Bewegungsproben) und
teils als uid://-Referenz (Szenenwechsel). Beide Formen werden hier auf den
gleichen res://-Pfad zurueckgefuehrt, bevor die Zuordnung greift.

## ANPASSEN ##
Die Zuordnung unten ist eine Modellierungsentscheidung. Bitte anhand des Spiels
pruefen und ggf. korrigieren -- sie beeinflusst die raeumlichen und
verhaltensbezogenen Features (Kapitel 5.2) unmittelbar.
"""

from __future__ import annotations

# Semantische Bereichstypen
INNEN = "innen"
AUSSEN = "aussen"          # Aussen- bzw. Erkundungsbereich
RAETSEL = "raetsel"
NARRATIV = "narrativ"
UNBEKANNT = "unbekannt"

ALL_AREA_TYPES = [INNEN, AUSSEN, RAETSEL, NARRATIV, UNBEKANNT]

# uid://-Referenz -> res://-Szenenpfad (aus den .tscn-Kopfzeilen des Repos).
# Nur Szenen, die als "Raum" in der Telemetrie auftreten koennen (Karten +
# Raetsel-Szenen). Beim Aktualisieren des Spiels ggf. neu erzeugen mit:
#   grep -rl 'uid="uid://' --include='*.tscn' scenes
_UID_TO_SCENE: dict[str, str] = {
    # -- Karten -------------------------------------------------------------
    "uid://csejhruust020": "res://scenes/maps/spaceship.tscn",
    "uid://n5pfeqsgykkm":  "res://scenes/maps/spaceship_room.tscn",
    "uid://b4r2irdvo1x1b": "res://scenes/maps/outside_1.tscn",
    "uid://34ylk7jtx176":  "res://scenes/maps/Outside_2/outside_2.tscn",
    "uid://cbsuctc5xrvkk": "res://scenes/maps/Outside_2/sams_cave.tscn",
    "uid://dlsjgc5i7yt81": "res://scenes/maps/Outside_3/Outside_3.tscn",
    "uid://ppgrh87b51qp":  "res://scenes/maps/Outside_4/Outside_4.tscn",
    "uid://dmkx8cyr3lsa6": "res://scenes/maps/Outside_4/temple.tscn",
    "uid://xmw3fst2nvqb":  "res://scenes/maps/pcg/map_generation.tscn",
    "uid://m8y5i5u6eyka":  "res://scenes/maps/transition_area_fade.tscn",
    # -- Raetsel-Szenen --------------------------------------------------
    "uid://bpvneidk4xerj": "res://scenes/Riddles/Spaceship/spaceship_door_riddle.tscn",
    "uid://cxue3cw47klvm": "res://scenes/Riddles/Outside_2/treasure_chest_riddle.tscn",
    "uid://dmlmv2sismu3p": "res://scenes/Riddles/mushroom/mushroom_riddle.tscn",
    "uid://dgxcraqxfqci7": "res://scenes/Riddles/riddle_statue/riddle_statue.tscn",
    "uid://bj5nyvggsxjwd": "res://scenes/Riddles/sky_puzzle/Moon_image_1.tscn",
    "uid://c1cu26niebyeg": "res://scenes/Riddles/sky_puzzle/flower_image_1.tscn",
    "uid://dwq6uqi88ie1h": "res://scenes/Riddles/sky_puzzle/mushroom_image_1.tscn",
    "uid://1gjnalxntxuw":  "res://scenes/Riddles/stonepuzzle/puzzle.tscn",
    "uid://illortuv3el6":  "res://scenes/Riddles/temple_door_riddle/temple_door.tscn",
}

# Substring des (kleingeschriebenen) Szenenpfads -> Bereichstyp.
# Reihenfolge = Prioritaet (erste Uebereinstimmung gewinnt).
_RULES: list[tuple[str, str]] = [
    ("spaceship_room", INNEN),
    ("spaceship", NARRATIV),      # Intro / Ausgangspunkt der Geschichte
    ("sams_cave", NARRATIV),      # Fund von Sam
    ("cave", NARRATIV),
    ("temple", RAETSEL),          # Tempel-/Saeulenraetsel
    ("riddles", RAETSEL),         # Ordner scenes/Riddles/...
    ("riddle", RAETSEL),
    ("puzzle", RAETSEL),
    ("outside_1", AUSSEN),
    ("outside_2", AUSSEN),
    ("outside_3", AUSSEN),
    ("outside_4", AUSSEN),
    ("outside", AUSSEN),
    ("map_generation", AUSSEN),
    ("pcg", AUSSEN),
]

# Optionale exakte Overrides (voller res://-Pfad -> Bereichstyp)
_EXACT_OVERRIDES: dict[str, str] = {}


def resolve_scene(scene_path: str | None) -> str:
    """uid://-Referenz auf den res://-Pfad abbilden (sonst unveraendert).

    Dient als kanonischer Schluessel: dieselbe Szene taucht in der Telemetrie
    mal als res://-Pfad (Bewegungsproben) und mal als uid://-Referenz
    (Szenenwechsel) auf.
    """
    if not scene_path:
        return ""
    key = str(scene_path).strip()
    if key.startswith("uid://"):
        return _UID_TO_SCENE.get(key, key)
    return key


# interner Alias (Rueckwaertskompatibilitaet)
_resolve = resolve_scene


def area_type_for(scene_path: str | None) -> str:
    """Gibt den Bereichstyp fuer einen Szenenpfad / eine Raumkennung zurueck."""
    if not scene_path:
        return UNBEKANNT
    resolved = resolve_scene(scene_path)
    if resolved in _EXACT_OVERRIDES:
        return _EXACT_OVERRIDES[resolved]
    lowered = resolved.lower()
    for needle, area_type in _RULES:
        if needle in lowered:
            return area_type
    return UNBEKANNT


def scene_name(scene_path: str | None) -> str:
    """Kurzname einer Szene (Dateiname ohne Pfad/Endung) fuer Beschriftungen."""
    if not scene_path:
        return "unknown"
    resolved = resolve_scene(scene_path)
    tail = resolved.replace("\\", "/").rstrip("/").split("/")[-1]
    for suffix in (".tscn", ".scn", ".res"):
        if tail.endswith(suffix):
            tail = tail[: -len(suffix)]
    return tail or "unknown"
