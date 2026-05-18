from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .telemetry_models import LoadReport, TelemetryEvent


class EventNormalizer:

    SEMANTIC_ALIASES = {
        "interaction_used": "interaction",
        "puzzle_ended": "puzzle_solved",
        "puzzle_finished": "puzzle_solved",
        "scene_changed": "scene_changed",
        "movement": "movement_sample",
        "movement_sample": "movement_sample",
        "dialog_choice": "dialog_choice",
        "dialog_started": "dialog_started",
        "dialog_finished": "dialog_finished",
        "quest_added": "quest_updated",
        "quest_updated": "quest_updated",
        "quest_completed": "quest_updated",
        "item_collected": "item_collected",
        "checkpoint_reached": "checkpoint_reached",
        "player_died": "player_died",
        "game_finished": "game_finished",
        "session_started": "session_started",
        "session_ended": "session_ended",
        "room_entered": "room_entered",
        "room_exited": "room_exited",
        "semantic": "semantic_snapshot",
        "semantic_snapshot": "semantic_snapshot",
    }

    def normalize_row(self, row: dict[str, Any]) -> list[TelemetryEvent]:
        flattened = self._flatten_row(row)
        session_id = self._as_string(flattened.get("session_id"))
        t_msec = self._as_float(flattened.get("t_msec"))
        if t_msec is None:
            return []

        raw_type = self._as_string(flattened.get("type"))
        raw_event = flattened.get("event_type")
        if raw_event is None:
            raw_event = flattened.get("event")
        raw_event = self._as_string(raw_event)
        room = self._detect_room(flattened)
        position = self._detect_position(flattened)
        metadata = self._build_metadata(flattened)

        if raw_type == "movement" or (position and raw_event in (None, "", "movement")):
            return [
                self._make_event(
                    session_id=session_id,
                    event_type="movement_sample",
                    t_msec=t_msec,
                    room=room,
                    position=position,
                    metadata=metadata,
                    raw=flattened,
                )
            ]

        if raw_type == "scene_changed" or raw_event == "scene_changed":
            return self._normalize_scene_change(flattened, session_id, t_msec, metadata, position)

        if raw_type == "semantic":
            context = self._as_string(flattened.get("context")) or "semantic_snapshot"
            metadata["context"] = context
            return [
                self._make_event(
                    session_id=session_id,
                    event_type="semantic_snapshot",
                    t_msec=t_msec,
                    room=room,
                    position=position,
                    metadata=metadata,
                    raw=flattened,
                )
            ]

        event_type = self.SEMANTIC_ALIASES.get(raw_event or raw_type or "", raw_event or raw_type or "unknown")
        return [
            self._make_event(
                session_id=session_id,
                event_type=event_type,
                t_msec=t_msec,
                room=room,
                position=position,
                metadata=metadata,
                raw=flattened,
            )
        ]

    def _normalize_scene_change(
        self,
        row: dict[str, Any],
        session_id: str | None,
        t_msec: float,
        metadata: dict[str, Any],
        position: dict[str, float] | None,
    ) -> list[TelemetryEvent]:
        from_room = self._as_string(row.get("from")) or self._as_string(row.get("from_room"))
        to_room = self._as_string(row.get("to")) or self._as_string(row.get("to_room")) or self._detect_room(row)
        base_metadata = dict(metadata)
        if from_room:
            base_metadata["from_room"] = from_room
        if to_room:
            base_metadata["to_room"] = to_room

        events = [
            self._make_event(
                session_id=session_id,
                event_type="scene_changed",
                t_msec=t_msec,
                room=to_room,
                position=position,
                metadata=base_metadata,
                raw=row,
            )
        ]
        if from_room:
            events.append(
                self._make_event(
                    session_id=session_id,
                    event_type="room_exited",
                    t_msec=t_msec,
                    room=from_room,
                    position=position,
                    metadata=base_metadata,
                    raw=row,
                )
            )
        if to_room:
            events.append(
                self._make_event(
                    session_id=session_id,
                    event_type="room_entered",
                    t_msec=t_msec,
                    room=to_room,
                    position=position,
                    metadata=base_metadata,
                    raw=row,
                )
            )
        return events

    def _flatten_row(self, row: dict[str, Any]) -> dict[str, Any]:
        event_obj = row.get("event")
        if isinstance(event_obj, dict):
            flattened = dict(row)
            flattened.pop("event", None)
            flattened.update(event_obj)
            features = event_obj.get("features")
            if isinstance(features, dict):
                flattened.setdefault("metadata", {})
                flattened["metadata"] = {
                    **flattened.get("metadata", {}),
                    "features": features,
                }
            return flattened
        return dict(row)

    def _build_metadata(self, row: dict[str, Any]) -> dict[str, Any]:
        reserved = {
            "session_id",
            "event",
            "event_type",
            "type",
            "t_msec",
            "room",
            "scene",
            "from",
            "to",
            "from_room",
            "to_room",
            "x",
            "y",
            "position",
        }
        metadata = dict(row.get("metadata", {})) if isinstance(row.get("metadata"), dict) else {}
        for key, value in row.items():
            if key not in reserved and key != "metadata":
                metadata.setdefault(key, value)
        return metadata

    def _detect_room(self, row: dict[str, Any]) -> str | None:
        room = (
            row.get("room")
            or row.get("current_area")
            or row.get("scene")
            or row.get("to")
            or row.get("to_room")
        )
        room = self._as_string(room)
        return room or None

    def _detect_position(self, row: dict[str, Any]) -> dict[str, float] | None:
        position = row.get("position")
        if isinstance(position, dict):
            x = self._as_float(position.get("x"))
            y = self._as_float(position.get("y"))
            if x is not None and y is not None:
                return {"x": x, "y": y}
        x = self._as_float(row.get("x"))
        y = self._as_float(row.get("y"))
        if x is None or y is None:
            return None
        return {"x": x, "y": y}

    def _make_event(
        self,
        session_id: str | None,
        event_type: str,
        t_msec: float,
        room: str | None,
        position: dict[str, float] | None,
        metadata: dict[str, Any],
        raw: dict[str, Any],
    ) -> TelemetryEvent:
        return TelemetryEvent(
            session_id=session_id,
            event_type=event_type,
            t_msec=t_msec,
            room=room,
            position=position,
            x=None if not position else position["x"],
            y=None if not position else position["y"],
            metadata=metadata,
            raw=raw,
        )

    @staticmethod
    def _as_string(value: Any) -> str | None:
        if value is None:
            return None
        text = str(value).strip()
        return text or None

    @staticmethod
    def _as_float(value: Any) -> float | None:
        try:
            if value is None:
                return None
            return float(value)
        except (TypeError, ValueError):
            return None


class TelemetryLoader:
    """Loads JSONL telemetry from a file or directory."""

    def __init__(self, normalizer: EventNormalizer | None = None) -> None:
        self.normalizer = normalizer or EventNormalizer()
        self.last_report = LoadReport()

    def load(self, input_path: str | Path) -> list[TelemetryEvent]:
        path = Path(input_path)
        report = LoadReport()
        events: list[TelemetryEvent] = []
        if path.is_dir():
            events.extend(self.load_jsonl_folder(path, report))
        else:
            events.extend(self.load_jsonl_file(path, report))
        self.last_report = report
        return events

    def load_jsonl_folder(self, path: str | Path, report: LoadReport | None = None) -> list[TelemetryEvent]:
        folder = Path(path)
        report = report or LoadReport()
        files = sorted(folder.glob("*.jsonl"))
        if not files:
            print(f"Keine .jsonl-Dateien in '{folder}'.")
            return []
        events: list[TelemetryEvent] = []
        for file_path in files:
            events.extend(self.load_jsonl_file(file_path, report))
        return events

    def load_jsonl_file(self, path: str | Path, report: LoadReport | None = None) -> list[TelemetryEvent]:
        file_path = Path(path)
        report = report or LoadReport()
        report.files_read += 1
        file_events: list[TelemetryEvent] = []
        raw_rows = 0
        skipped = 0
        if not file_path.exists():
            print(f"Datei nicht gefunden: {file_path}")
            return []
        with file_path.open("r", encoding="utf-8") as handle:
            for line in handle:
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except json.JSONDecodeError:
                    skipped += 1
                    continue
                raw_rows += 1
                file_events.extend(self.normalizer.normalize_row(row))
        report.raw_rows += raw_rows
        report.skipped_lines += skipped
        report.normalized_events += len(file_events)
        print(
            f"  {file_path.name}: {raw_rows} Zeilen, "
            f"{len(file_events)} normalisierte Events, {skipped} übersprungen"
        )
        return file_events
