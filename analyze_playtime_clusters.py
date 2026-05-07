"""Playtime-clustering wrapper for the shared telemetry analysis pipeline."""

from __future__ import annotations

import sys

from analysis import AnalysisPipeline


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python analyze_playtime_clusters.py <analytics.jsonl|ordner> <output_dir>")
        return 1
    pipeline = AnalysisPipeline()
    pipeline.run(
        sys.argv[1],
        sys.argv[2],
        include_clusters=True,
        include_room_analysis=False,
        include_semantic_analysis=False,
        include_playtrace=False,
    )
    print("\nFertig.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
