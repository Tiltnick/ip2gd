"""Kleines Demo-Skript für K-Means-Clusterer (Beispieldaten).

Ausführung:
    python -m ip2gd.analysis.run_kmeans_demo

Das Skript erstellt synthetische Sessions mit mehreren Zeit-Features,
führt das Clustering durch und druckt angereicherte Sessions + Zusammenfassung.
"""

from __future__ import annotations

from pprint import pprint

from ip2gd.analysis.kmeans_playtime_clusterer import KMeansPlaytimeClusterer


def make_sample_sessions():
    sessions = []
    sid = 0
    def s(**kwargs):
        nonlocal sid
        sid += 1
        base_msec = int(kwargs.get("playtime_minutes", 10) * 60000)
        return {
            "session_id": f"session_{sid}",
            "start_msec": 0,
            "end_msec": base_msec,
            "playtime_msec": base_msec,
            "playtime_seconds": base_msec / 1000.0,
            "playtime_minutes": float(kwargs.get("playtime_minutes", 10.0)),
            "event_count": float(kwargs.get("event_count", 20)),
            # optional detailed features (minutes)
            "walk_minutes": float(kwargs.get("walk_minutes", 0.0)),
            "run_minutes": float(kwargs.get("run_minutes", 0.0)),
            "dialogue_minutes": float(kwargs.get("dialogue_minutes", 0.0)),
            "quest_duration_minutes": float(kwargs.get("quest_duration_minutes", 0.0)),
            "puzzle_duration_minutes": float(kwargs.get("puzzle_duration_minutes", 0.0)),
        }

    # schnelle Spieler (kurze Gesamtzeiten, viel laufen/rennen)
    sessions.append(s(playtime_minutes=3.2, walk_minutes=1.2, run_minutes=1.5, dialogue_minutes=0.3, quest_duration_minutes=0.5, puzzle_duration_minutes=0.2))
    sessions.append(s(playtime_minutes=4.0, walk_minutes=1.6, run_minutes=1.9, dialogue_minutes=0.2, quest_duration_minutes=0.3, puzzle_duration_minutes=0.0))
    sessions.append(s(playtime_minutes=2.5, walk_minutes=1.0, run_minutes=1.2, dialogue_minutes=0.2, quest_duration_minutes=0.0, puzzle_duration_minutes=0.1))

    # Standard-Spieler
    sessions.append(s(playtime_minutes=12.0, walk_minutes=6.0, run_minutes=2.0, dialogue_minutes=3.5, quest_duration_minutes=4.0, puzzle_duration_minutes=1.0))
    sessions.append(s(playtime_minutes=9.5, walk_minutes=5.0, run_minutes=1.0, dialogue_minutes=2.5, quest_duration_minutes=2.0, puzzle_duration_minutes=0.5))
    sessions.append(s(playtime_minutes=11.0, walk_minutes=6.5, run_minutes=1.2, dialogue_minutes=2.8, quest_duration_minutes=3.0, puzzle_duration_minutes=0.8))

    # langsame Spieler (lange Spielzeiten, viele Dialoge/Quests)
    sessions.append(s(playtime_minutes=35.0, walk_minutes=15.0, run_minutes=2.0, dialogue_minutes=12.0, quest_duration_minutes=10.0, puzzle_duration_minutes=2.0))
    sessions.append(s(playtime_minutes=28.0, walk_minutes=12.0, run_minutes=1.5, dialogue_minutes=8.0, quest_duration_minutes=7.0, puzzle_duration_minutes=1.5))
    sessions.append(s(playtime_minutes=40.0, walk_minutes=18.0, run_minutes=2.5, dialogue_minutes=10.0, quest_duration_minutes=11.0, puzzle_duration_minutes=3.0))

    # Edge cases / missing features
    sessions.append(s(playtime_minutes=6.0, walk_minutes=4.0))
    sessions.append(s(playtime_minutes=0.5, walk_minutes=0.3, run_minutes=0.1))
    sessions.append(s(playtime_minutes=18.0, dialogue_minutes=6.0, quest_duration_minutes=5.0))

    return sessions


def main():
    print("Erstelle Beispieldaten...")
    sessions = make_sample_sessions()
    pprint(sessions)

    clusterer = KMeansPlaytimeClusterer()
    feature_keys = [
        "walk_minutes",
        "run_minutes",
        "dialogue_minutes",
        "quest_duration_minutes",
        "puzzle_duration_minutes",
    ]

    print("\nFühre Clustering aus (k=3) auf feature_keys:\n", feature_keys)
    enriched, elbow = clusterer.cluster_playtimes(sessions, final_k=3, max_k=6, feature_keys=feature_keys)
    if enriched is None:
        print("Clustering wurde übersprungen (zu wenig Daten oder sklearn fehlt).")
        return

    print("\nAngereicherte Sessions:")
    pprint(enriched)

    summary = clusterer.build_cluster_summary(enriched, feature_keys=feature_keys)
    print("\nCluster-Zusammenfassung:")
    pprint(summary)

    print("\nElbow-Daten (k,inertia):")
    pprint(elbow)


if __name__ == "__main__":
    main()
