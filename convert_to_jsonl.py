"""
convert_to_jsonl.py – Konvertiert trajectories.json zu JSONL-Format

Diese Datei konvertiert die trajectories.json Datei in das JSONL-Format,
das von run_analysis.py verarbeitet wird.

Aufruf:
  python convert_to_jsonl.py
"""

import json
import os

def convert_trajectories_to_jsonl():
    """Konvertiert trajectories.json zu analytics.jsonl
    
    Jedes Event aus der Sequence wird als separate JSONL-Zeile geschrieben,
    damit run_analysis.py session_id und t_msec verarbeiten kann.
    """
    
    input_file = "outputpython/trajectories.json"
    output_file = "outputpython/analytics.jsonl"
    
    if not os.path.exists(input_file):
        print(f"Fehler: {input_file} nicht gefunden.")
        return False
    
    # Lade trajectories.json
    with open(input_file, "r", encoding="utf-8") as f:
        attempts = json.load(f)
    
    print(f"Lade {input_file}...")
    print(f"Anzahl Attempts: {len(attempts)}")
    
    # Schreibe JSONL-Datei: jedes Event als separate Zeile
    written_lines = 0
    with open(output_file, "w", encoding="utf-8") as f:
        for attempt in attempts:
            session_id = attempt.get("session_id", "unknown")
            sequence = attempt.get("sequence", [])
            
            # Schreibe jedes Event aus der Sequence als separate Zeile
            for event in sequence:
                # Füge session_id auf der obersten Ebene hinzu
                line_obj = {
                    "session_id": session_id,
                    "t_msec": event.get("t_msec"),
                    "event": event,
                    "attempt": attempt
                }
                json.dump(line_obj, f, ensure_ascii=False)
                f.write("\n")
                written_lines += 1
    
    print(f"\nKonvertierung erfolgreich!")
    print(f"  Input: {input_file} ({len(attempts)} Attempts)")
    print(f"  Output: {output_file} ({written_lines} Zeilen / Events)")
    print(f"\nNächster Schritt:")
    print(f"  python run_analysis.py {output_file} outputpython/analysis")
    
    return True

if __name__ == "__main__":
    convert_trajectories_to_jsonl()
