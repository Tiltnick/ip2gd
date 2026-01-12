# DialogManager

Der **DialogManager** ist für die vollständige Steuerung aller Dialoge im Spiel verantwortlich.  
Er koordiniert das Laden der Dialogdaten, den Ablauf einzelner Dialoge, die Verarbeitung von Spielerentscheidungen sowie die Kommunikation mit anderen Spielsystemen.

Der DialogManager selbst übernimmt **keine visuelle Darstellung**, sondern fungiert ausschließlich als logische Steuerinstanz.

---

## Allgemeine Struktur

Der DialogManager ist als `CanvasLayer` umgesetzt und nutzt eine separate **DialogBox-Szene** für sämtliche UI-Elemente.

Hauptaufgaben des DialogManagers:

- Laden von Dialogdaten aus JSON-Dateien  
- Steuerung des Dialogablaufs (Textzeilen, Auswahloptionen, Verzweigungen)  
- Kommunikation mit anderen Spielsystemen (z. B. GameState, Puzzle-Flags)  
- Starten und Beenden von Dialogen  

---

## DialogBox

Die **DialogBox** ist für die komplette Benutzeroberfläche des Dialogsystems zuständig.

Zu ihren Aufgaben gehören:

- Anzeige des aktuellen Sprechers  
- Darstellung des Dialogtexts mit Typewriter-Effekt  
- Anzeigen von Charakterportraits  
- Erzeugen und Verwalten von Auswahlbuttons  
- Verarbeitung von Spieler-Input (Weiter, Auswahl treffen)

### Signale

Die DialogBox sendet Signale an den DialogManager, wenn:

- der Spieler den Dialog fortsetzt  
- eine Auswahloption ausgewählt wurde  

Der DialogManager reagiert auf diese Signale und steuert entsprechend den weiteren Ablauf des Dialogs.

---

## DialogParser

Der **DialogParser** ist für das Einlesen und Interpretieren der Dialogdaten zuständig.  
Er arbeitet vollständig datengetrieben und besitzt **keinen direkten Bezug zur Benutzeroberfläche**.

### Aufgaben des DialogParsers

- Laden und Validieren von Dialog-JSON-Dateien  
- Verwalten des aktuellen Dialogknotens  
- Verwalten der aktuellen Dialogzeile  
- Bereitstellen der aktuellen Dialogzeile für den DialogManager  
- Bereitstellen verfügbarer Auswahlmöglichkeiten  
- Verarbeiten von Verzweigungen und Übergängen zwischen Dialogknoten  
- Unterstützung von Sprachen (`text_en`, `text_de`)  

---

## Dialogablauf (Übersicht)

1. Ein Dialog wird über `start_dialog(json_path)` gestartet  
2. Der DialogParser lädt die entsprechende JSON-Datei  
3. Der DialogManager fordert die aktuelle Dialogzeile vom Parser an  
4. Die DialogBox stellt die Zeile visuell dar  
5. Der Spieler schreitet per Input durch den Dialog voran  
6. Falls Auswahlmöglichkeiten vorhanden sind, werden diese angezeigt  
7. Die getroffene Auswahl bestimmt den nächsten Dialogknoten  
8. Nach dem Ende des Dialogs informiert der DialogManager andere Spielsysteme und aktualisiert relevante Zustände  

---

## Dialog-JSON-Format

Dialoge sind als **JSON-Dateien** organisiert und folgen einer knotebasierten Struktur.

### Grundstruktur

- **`characters`**  
  Ordnet Charakternamen die entsprechenden Portrait-Texturen zu  

- **`steps`**  
  Enthält alle Dialogknoten  

Jeder Dialog beginnt im Knoten `sections` und endet im Knoten `end`.

---

## Dialogzeilen

Ein Dialogknoten kann mehrere `lines` enthalten.  
Jede Dialogzeile besteht aus:

- `speaker` – Name des sprechenden Charakters  
- `text_en` – Englischer Dialogtext  
- `text_de` – Deutscher Dialogtext  

### Beispiel

```json
{
  "speaker": "Mr. Blob",
  "text_en": "Hello there strange creature!",
  "text_de": "Hallo du seltsame Kreatur!"
}
