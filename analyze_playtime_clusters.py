"""
analyze_playtime_clusters.py  –  K-Means Spielzeit-Clustering

Teil 3 – K-Means Spielzeit-Clustering:
  • Berechnet die Spielzeit pro Session aus den JSONL-Trackingdaten.
  • Teilt Sessions per K-Means (k=3) in drei Spielertypen ein:
      - schnelle Spieler
      - durchschnittliche Spieler
      - langsamere Spieler
  • Ausgaben: CSV, JSON, Elbow-Plot, Cluster-Plot

Aufruf:
  python analyze_playtime_clusters.py <analytics_ordner_oder_datei> <output_dir>
"""

import csv
import glob
import json
import os
import sys
from collections import defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

try:
    from sklearn.cluster import KMeans
    from sklearn.preprocessing import StandardScaler
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False
    print("Hinweis: scikit-learn nicht installiert – K-Means-Spielzeit-Clustering wird übersprungen.")
    print("  pip install scikit-learn")


# ══════════════════════════════════════════════════════════════════════════════
# LADEN
# ══════════════════════════════════════════════════════════════════════════════

def load_all(input_path):
    """Lädt alle JSONL-Zeilen aus einer Datei oder einem Ordner."""
    if os.path.isdir(input_path):
        files = sorted(glob.glob(os.path.join(input_path, "*.jsonl")))
        if not files:
            print(f"Keine .jsonl-Dateien in '{input_path}'.")
            sys.exit(1)
    else:
        files = [input_path]

    all_rows = []
    for f in files:
        count = 0
        with open(f, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    all_rows.append(json.loads(line))
                    count += 1
                except json.JSONDecodeError:
                    continue
        print(f"  {os.path.basename(f)}: {count} Zeilen")
    return all_rows


# ══════════════════════════════════════════════════════════════════════════════
# SPIELZEIT-BERECHNUNG
# ══════════════════════════════════════════════════════════════════════════════

def compute_session_playtimes(all_rows):
    """
    Gruppiert alle Events nach session_id und berechnet die Spielzeit pro Session.

    Returns:
        list of dict with keys:
          session_id, playtime_msec, playtime_seconds, playtime_minutes
    """
    by_session = defaultdict(list)
    for r in all_rows:
        sid = r.get("session_id")
        if sid is None:
            sid = "unknown"
        t = r.get("t_msec")
        if t is not None:
            try:
                by_session[sid].append(float(t))
            except (TypeError, ValueError):
                continue

    results = []
    for sid, times in by_session.items():
        if len(times) < 2:
            continue
        playtime_msec = max(times) - min(times)
        if playtime_msec <= 0:
            continue
        results.append({
            "session_id": sid,
            "playtime_msec": playtime_msec,
            "playtime_seconds": playtime_msec / 1000.0,
            "playtime_minutes": playtime_msec / 60000.0,
        })

    return results


# ══════════════════════════════════════════════════════════════════════════════
# ELBOW-METHODE
# ══════════════════════════════════════════════════════════════════════════════

def run_elbow_method(X_scaled, max_k):
    """
    Berechnet die Inertia für k=1 bis max_k.

    Returns:
        list of (k, inertia) tuples
    """
    results = []
    for k in range(1, max_k + 1):
        km = KMeans(n_clusters=k, random_state=42, n_init="auto")
        km.fit(X_scaled)
        results.append((k, km.inertia_))
    return results


def save_elbow_plot(elbow_data, final_k, output_dir):
    """Speichert den Elbow-Method-Plot als PNG."""
    ks = [d[0] for d in elbow_data]
    inertias = [d[1] for d in elbow_data]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ks, inertias, marker="o", color="#4466aa", linewidth=2, markersize=6)

    # Markierung für final verwendetes k=3
    if final_k in ks:
        idx = ks.index(final_k)
        ax.axvline(x=final_k, color="red", linestyle="--", alpha=0.7,
                   label=f"Final k={final_k} (verwendete Clusteranzahl)")
        ax.scatter([final_k], [inertias[idx]], color="red", zorder=5, s=80)

    ax.set_xlabel("Anzahl Cluster k", fontsize=12)
    ax.set_ylabel("Inertia / WCSS", fontsize=12)
    ax.set_title("Elbow Method – Spielzeit-Clustering", fontsize=13)
    ax.set_xticks(ks)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()

    out_path = os.path.join(output_dir, "playtime_elbow_method.png")
    fig.savefig(out_path, dpi=150)
    plt.close(fig)
    return out_path


# ══════════════════════════════════════════════════════════════════════════════
# K-MEANS CLUSTERING
# ══════════════════════════════════════════════════════════════════════════════

PLAYER_TYPE_LABELS = ["schnelle Spieler", "durchschnittliche Spieler", "langsamere Spieler"]


def run_playtime_kmeans(playtimes, output_dir):
    """
    Führt K-Means mit k=3 auf den Spielzeiten durch.
    Sorted die Cluster anhand ihrer Centroids (niedrigste → schnelle Spieler).

    Args:
        playtimes: list of dicts (Ergebnis von compute_session_playtimes)
        output_dir: Ausgabeordner

    Returns:
        list of dicts with cluster_id and player_type added,
        or None if not enough sessions
    """
    if len(playtimes) < 3:
        print(f"Zu wenige Sessions für K-Means mit 3 Clustern. Mindestens 3 Sessions erforderlich.")
        return None

    minutes = [[p["playtime_minutes"]] for p in playtimes]
    X = np.array(minutes)

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Elbow-Methode
    max_k = min(10, len(playtimes))
    print(f"  Elbow-Methode: berechne k=1 bis k={max_k}...")
    elbow_data = run_elbow_method(X_scaled, max_k)
    elbow_path = save_elbow_plot(elbow_data, final_k=3, output_dir=output_dir)
    print(f"  Elbow-Plot gespeichert: {elbow_path}")

    # Finales K-Means mit k=3
    km = KMeans(n_clusters=3, random_state=42, n_init="auto")
    km.fit(X_scaled)
    labels = km.labels_

    # Centroids zurück in Original-Skala transformieren
    centroids_original = scaler.inverse_transform(km.cluster_centers_)
    # Sortiere Cluster-IDs nach aufsteigender Centroid-Spielzeit
    sorted_cluster_ids = np.argsort(centroids_original[:, 0])
    # Mapping: raw cluster_id → sortierter Index (0=schnell, 1=mittel, 2=langsam)
    cluster_rank = {int(cid): rank for rank, cid in enumerate(sorted_cluster_ids)}

    enriched = []
    for i, p in enumerate(playtimes):
        raw_cid = int(labels[i])
        rank = cluster_rank[raw_cid]
        enriched.append({
            **p,
            "cluster_id": rank,
            "player_type": PLAYER_TYPE_LABELS[rank],
        })

    return enriched, elbow_path


# ══════════════════════════════════════════════════════════════════════════════
# SPEICHERN
# ══════════════════════════════════════════════════════════════════════════════

def save_playtime_cluster_csv(enriched, output_dir):
    """Speichert die Cluster-Ergebnisse als CSV."""
    out_path = os.path.join(output_dir, "playtime_clusters.csv")
    fieldnames = ["session_id", "playtime_msec", "playtime_seconds", "playtime_minutes",
                  "cluster_id", "player_type"]
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in enriched:
            writer.writerow({k: row[k] for k in fieldnames})
    return out_path


def save_playtime_cluster_json(enriched, output_dir):
    """Speichert die Cluster-Ergebnisse als JSON inkl. Cluster-Zusammenfassung."""
    # Cluster-Zusammenfassung berechnen
    by_type = defaultdict(list)
    for row in enriched:
        by_type[row["cluster_id"]].append(row["playtime_minutes"])

    summary = []
    for cid in sorted(by_type.keys()):
        mins = by_type[cid]
        summary.append({
            "player_type": PLAYER_TYPE_LABELS[cid],
            "cluster_id": cid,
            "anzahl_sessions": len(mins),
            "min_playtime_minutes": round(min(mins), 4),
            "max_playtime_minutes": round(max(mins), 4),
            "avg_playtime_minutes": round(sum(mins) / len(mins), 4),
        })

    sessions_out = []
    for row in enriched:
        sessions_out.append({
            "session_id": row["session_id"],
            "playtime_msec": row["playtime_msec"],
            "playtime_seconds": round(row["playtime_seconds"], 3),
            "playtime_minutes": round(row["playtime_minutes"], 4),
            "cluster_id": row["cluster_id"],
            "player_type": row["player_type"],
        })

    output = {
        "sessions": sessions_out,
        "cluster_summary": summary,
    }

    out_path = os.path.join(output_dir, "playtime_clusters.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    return out_path


def save_cluster_plot(enriched, output_dir):
    """Speichert den K-Means Cluster-Plot als PNG."""
    # Sortiere Sessions nach Spielzeit für übersichtliche Darstellung
    sorted_data = sorted(enriched, key=lambda x: x["playtime_minutes"])

    colors = {0: "#2ecc71", 1: "#3498db", 2: "#e74c3c"}
    color_map = {label: colors[i] for i, label in enumerate(PLAYER_TYPE_LABELS)}

    fig, ax = plt.subplots(figsize=(10, 6))

    plotted_labels = set()
    for idx, row in enumerate(sorted_data):
        ptype = row["player_type"]
        col = color_map[ptype]
        label = ptype if ptype not in plotted_labels else None
        ax.scatter(idx, row["playtime_minutes"], color=col, label=label,
                   s=60, alpha=0.8, edgecolors="white", linewidths=0.5)
        plotted_labels.add(ptype)

    ax.set_xlabel("Session-Index (nach Spielzeit sortiert)", fontsize=11)
    ax.set_ylabel("Spielzeit in Minuten", fontsize=11)
    ax.set_title("K-Means Spielzeit-Clustering – 3 Spielertypen", fontsize=13)
    ax.legend(title="Spielertyp", fontsize=9, title_fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()

    out_path = os.path.join(output_dir, "playtime_kmeans_clusters.png")
    fig.savefig(out_path, dpi=150)
    plt.close(fig)
    return out_path


# ══════════════════════════════════════════════════════════════════════════════
# KONSOLENAUSGABE
# ══════════════════════════════════════════════════════════════════════════════

def print_summary(enriched, elbow_path, cluster_path, csv_path, json_path):
    """Gibt eine verständliche Zusammenfassung der Clustering-Ergebnisse aus."""
    by_type = defaultdict(list)
    for row in enriched:
        by_type[row["player_type"]].append(row["playtime_minutes"])

    print(f"\nTeil 3 – K-Means Spielzeit-Clustering:")
    print(f"  Sessions ausgewertet: {len(enriched)}")
    for label in PLAYER_TYPE_LABELS:
        mins = by_type.get(label, [])
        avg = sum(mins) / len(mins) if mins else 0.0
        label_cap = label[0].upper() + label[1:]
        print(f"  {label_cap}: {len(mins)} Sessions, Ø {avg:.2f} Minuten")
    print(f"  Elbow-Plot gespeichert: {elbow_path}")
    print(f"  Cluster-Plot gespeichert: {cluster_path}")
    print(f"  CSV gespeichert: {csv_path}")
    print(f"  JSON gespeichert: {json_path}")


# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════

def main():
    if len(sys.argv) < 3:
        print("Usage: python analyze_playtime_clusters.py <analytics.jsonl|ordner> <output_dir>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_dir = sys.argv[2]
    os.makedirs(output_dir, exist_ok=True)

    if not HAS_SKLEARN:
        sys.exit(0)

    print("Lade Daten...")
    all_rows = load_all(input_path)
    print(f"  Gesamt: {len(all_rows)} Zeilen\n")

    print("Teil 3 – K-Means Spielzeit-Clustering:")

    playtimes = compute_session_playtimes(all_rows)
    if not playtimes:
        print("  Keine gültigen t_msec-Werte gefunden – Analyse wird übersprungen.")
        sys.exit(0)

    print(f"  Gültige Sessions mit Spielzeitdaten: {len(playtimes)}")

    result = run_playtime_kmeans(playtimes, output_dir)
    if result is None:
        sys.exit(0)

    enriched, elbow_path = result
    cluster_path = save_cluster_plot(enriched, output_dir)
    csv_path = save_playtime_cluster_csv(enriched, output_dir)
    json_path = save_playtime_cluster_json(enriched, output_dir)

    print_summary(enriched, elbow_path, cluster_path, csv_path, json_path)
    print("\nFertig.")


if __name__ == "__main__":
    main()
