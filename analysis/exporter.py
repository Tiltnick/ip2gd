"""Centralized export helpers."""

from __future__ import annotations

import csv
import json
from pathlib import Path
from typing import Any


class TelemetryExporter:
    """Writes analysis artifacts to disk."""

    def __init__(self, output_dir: str | Path) -> None:
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def path(self, filename: str) -> Path:
        return self.output_dir / filename

    def save_csv(self, filename: str, rows: list[dict[str, Any]], fieldnames: list[str]) -> Path:
        path = self.path(filename)
        with path.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fieldnames)
            writer.writeheader()
            for row in rows:
                writer.writerow({field: row.get(field) for field in fieldnames})
        print(f"  CSV gespeichert: {path}")
        return path

    def save_json(self, filename: str, payload: dict[str, Any] | list[dict[str, Any]]) -> Path:
        path = self.path(filename)
        with path.open("w", encoding="utf-8") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2)
        print(f"  JSON gespeichert: {path}")
        return path
