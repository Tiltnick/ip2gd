"""CLI-Einstiegspunkt fuer die feature-basierte Telemetrieanalyse (Kapitel 5.2-5.4).

Aufruf:
  python run_feature_analysis.py [input] [output_dir] [Optionen]

  input       Pfad zu einer .jsonl-Datei ODER ein Ordner mit den rohen
              Session-Logs (game_*.jsonl / movement_*.jsonl / events_*.jsonl).
              Standard: outputpython/analytics.jsonl
  output_dir  Zielordner. Standard: outputpython/features

Optionen:
  --k N            feste Clusteranzahl erzwingen (statt Silhouette)
  --until S1,S2    Sessions ab dem ersten Betreten einer dieser Szenen
                   abschneiden. Standard: outside_3,outside_4,temple,
                   sams_cave,map_generation,ending_scene. "" schaltet ab.
  --max-minutes M  zusaetzliche harte Zeitobergrenze je Session
"""

from __future__ import annotations

import argparse

from analysis.feature_pipeline import FeatureAnalysisPipeline
from analysis.session_window import DEFAULT_STOP_SCENES


def main() -> int:
    parser = argparse.ArgumentParser(description="Feature-basierte Telemetrieanalyse")
    parser.add_argument("input_path", nargs="?", default="outputpython/analytics.jsonl")
    parser.add_argument("output_dir", nargs="?", default="outputpython/features")
    parser.add_argument("--k", type=int, default=None, help="feste Clusteranzahl erzwingen (statt Silhouette)")
    parser.add_argument(
        "--until",
        default=",".join(DEFAULT_STOP_SCENES),
        help='Stopp-Szenen (Komma-getrennt); "" schaltet den Zuschnitt ab',
    )
    parser.add_argument("--max-minutes", type=float, default=None, help="harte Zeitobergrenze je Session")
    args = parser.parse_args()

    stop_scenes = [s for s in args.until.split(",") if s.strip()] if args.until.strip() else []

    FeatureAnalysisPipeline().run(
        args.input_path,
        args.output_dir,
        final_k=args.k,
        stop_scenes=stop_scenes,
        max_minutes=args.max_minutes,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
