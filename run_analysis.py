"""CLI entrypoint for the telemetry analysis pipeline."""

from __future__ import annotations

import sys

from analysis import AnalysisPipeline


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: python run_analysis.py <analytics.jsonl|ordner> <output_dir>")
        return 1
    pipeline = AnalysisPipeline()
    pipeline.run(sys.argv[1], sys.argv[2])
    print("\nFertig.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
