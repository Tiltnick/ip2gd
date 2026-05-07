"""CLI entrypoint for the telemetry analysis pipeline."""

from __future__ import annotations

import argparse

from analysis import AnalysisPipeline


def main() -> int:
    parser = argparse.ArgumentParser(description="Telemetry analysis pipeline")
    parser.add_argument(
        "input_path",
        nargs="?",
        default="outputpython/analytics.jsonl",
        help="Path to analytics.jsonl or folder with *.jsonl files (default: outputpython/analytics.jsonl)",
    )
    parser.add_argument(
        "output_dir",
        nargs="?",
        default="outputpython/analysis",
        help="Output folder for exports and plots (default: outputpython/analysis)",
    )
    args = parser.parse_args()
    pipeline = AnalysisPipeline()
    pipeline.run(args.input_path, args.output_dir)
    print("\nFertig.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
