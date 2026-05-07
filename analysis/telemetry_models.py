"""Telemetry data models."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(slots=True)
class TelemetryEvent:
    """Normalized telemetry event."""

    session_id: str | None
    event_type: str
    t_msec: float
    room: str | None = None
    position: dict[str, float] | None = None
    x: float | None = None
    y: float | None = None
    metadata: dict[str, Any] = field(default_factory=dict)
    raw: dict[str, Any] = field(default_factory=dict)


@dataclass(slots=True)
class LoadReport:
    """Loader summary."""

    files_read: int = 0
    raw_rows: int = 0
    normalized_events: int = 0
    skipped_lines: int = 0
