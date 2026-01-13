# AudioManager

Der **AudioManager** ist eine zentrale Szene, die für die gesamte Audiosteuerung des Spiels verantwortlich ist.  
Er übernimmt das Abspielen von Hintergrundmusik (BGM), Soundeffekten (SFX) sowie die Verwaltung der globalen Lautstärkeeinstellungen.

---

## Szenenstruktur

Die AudioManager-Szene besitzt **zwei Child-Nodes**:

- **`bgm_player`**  
  Zuständig für die Wiedergabe von Hintergrundmusik.

- **`sfx_player`**  
  Zuständig für die Wiedergabe von Soundeffekten.

Beide Player sind technisch identisch aufgebaut. Sie unterscheiden sich lediglich in ihrer Verwendung.

---

## AudioManager-Script

Am AudioManager ist ein Script angebracht, das hauptsächlich für die **Lautstärkeregelung** zuständig ist.

### Lautstärkeverwaltung

- Die Lautstärke wird intern in **Dezibel (dB)** verarbeitet.
- Der zulässige Wertebereich liegt zwischen:
  - **Maximum:** `-8 dB`
  - **Minimum:** `-80 dB`
- Die Lautstärkeeinstellung des Spielers wird im **Optionsmenü** als Prozentwert (0–100 %) gespeichert.
- Dieser Prozentwert wird im AudioManager in einen entsprechenden dB-Wert umgerechnet und an die Player weitergegeben.

---

## Autoload-Konfiguration

Der AudioManager ist als **Autoload** eingerichtet.  
Dadurch ist er global verfügbar und kann von jeder Stelle im Projekt aus verwendet werden, ohne explizite Referenzen auf die Szene zu benötigen.

Ein zusätzlicher `WorldAudioManager` ist in diesem Setup **nicht erforderlich** und wird nicht verwendet.

---

## Abspielen von Audio

Je nach Art des Sounds wird der passende Player genutzt:

- Hintergrundmusik → `bgm_player`
- Soundeffekte → `sfx_player`

### Audiodateien

- Die Dateipfade aller Musikstücke und Soundeffekte sind in Variablen hinterlegt.
- Jeder Sound bzw. jeder Musiktrack besitzt eine **eigene Funktion**.
- Diese Funktionen laden die jeweilige Audiodatei und starten die Wiedergabe über den vorgesehenen Player.

---

## Hinzufügen neuer Sounds

Neue Sounds werden nach einem festen Schema integriert:

1. Prüfen, ob bereits eine passende Funktion existiert  
2. Falls nicht, eine neue Funktion nach dem bestehenden Muster anlegen  
3. Diese Funktion an der gewünschten Stelle im Code aufrufen  

### Beispiel

```gdscript
sfx_player.ui_click_sound()
