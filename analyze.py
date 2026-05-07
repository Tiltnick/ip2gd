"""Backward-compatible wrapper for the shared telemetry analysis pipeline."""

from run_analysis import main


if __name__ == "__main__":
    raise SystemExit(main())
