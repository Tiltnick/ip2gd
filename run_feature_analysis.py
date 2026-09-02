"""CLI-Einstiegspunkt für die feature-basierte Telemetrieanalyse (Kapitel 5.2-5.4).

Aufruf:
  python run_feature_analysis.py [input] [output_dir]

  input       Pfad zu einer .jsonl-Datei ODER ein Ordner mit den rohen
              Session-Logs (game_*.jsonl / movement_*.jsonl / events_*.jsonl).
              Standard: outputpython/analytics.jsonl
  output_dir  Zielordner. Standard: outputpython/features
"""

from __future__ import annotations

import argparse

from analysis.feature_pipeline import FeatureAnalysisPipeline


def main() -> int:
    parser = argparse.ArgumentParser(description="Feature-basierte Telemetrieanalyse")
    parser.add_argument("input_path", nargs="?", default="outputpython/analytics.jsonl")
    parser.add_argument("output_dir", nargs="?", default="outputpython/features")
    parser.add_argument("--k", type=int, default=None, help="feste Clusteranzahl erzwingen (statt Silhouette)")
    args = parser.parse_args()

    FeatureAnalysisPipeline().run(args.input_path, args.output_dir, final_k=args.k)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
