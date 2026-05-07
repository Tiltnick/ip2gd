"""Event-focused wrapper for the shared telemetry analysis pipeline."""

from __future__ import annotations

import sys

from analysis import AnalysisPipeline


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python analyze_events.py <analytics.jsonl|ordner> <output_dir>")
        return 1
    pipeline = AnalysisPipeline()
    pipeline.run(
        sys.argv[1],
        sys.argv[2],
        include_clusters=False,
        include_room_analysis=True,
        include_semantic_analysis=True,
        include_playtrace=True,
    )
    print("\nFertig.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
