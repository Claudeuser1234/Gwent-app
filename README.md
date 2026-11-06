# Gwent Apps

Zwei kleine Android-Apps für das Brettspiel Gwent mit den fünf klassischen Fraktionen: Königreiche des Nordens, Nilfgaard, Scoia'tael, Monster und Skellige.

| App | Datei | Was sie kann |
| --- | --- | --- |
| **Gwent Fraktionen** | `release/Gwent-Fraktionen.apk` | Fraktionen für 1 bis 5 Spieler auslosen |
| **Gwent Plus** | `release/Gwent-Plus.apk` | Spielmodus wählen, Fraktionen auslosen oder selbst verteilen, danach Punkte zählen |

Beide Apps lassen sich gleichzeitig installieren und laufen komplett offline.

## Gwent Plus

**Seite 1, Neues Spiel:** Du wählst den Spielmodus, die Spielerzahl und die Namen. Die Fraktionen tippst du an oder lässt sie auslosen. „Spiel starten“ öffnet den Punktezähler.

**Seite 2, Punktezähler:** Jeder Spieler bekommt ein Feld in seiner Fraktionsfarbe, mit dem Fraktionssymbol oben in der Ecke.

- **− / + tippen:** ±1
- **Halten:** ±10, und weiter ±10, solange du hältst
- **Zahl antippen:** Wert direkt eingeben
- **Pfeil:** macht das letzte Rundenende rückgängig
- **Zurück-Taste von Android:** führt vom Zähler zurück zur Einrichtung

Der Bildschirm bleibt an, solange die App offen ist.

### Spielmodi

**Duell (2 Spieler).** Jeder hat 2 Edelsteine. Wer eine Runde verliert, gibt einen ab. Bei Gleichstand verlieren beide einen, ausser einer spielt Nilfgaard: Nilfgaard gewinnt dann die Runde.

**Alle gegen Alle (3 bis 5 Spieler).** Es gibt keine Rundenbegrenzung. Am Rundenende bekommt jeder 1 Siegpunkt für jeden Gegner, dessen Stärke er übertrifft. Gleichstand zählt nicht, ausser für Nilfgaard. Spielen mehrere Nilfgaard und haben gleich viel, bekommen sie je 1 Punkt.

| Spieler | Ziel |
| --- | --- |
| 3 | 4 Siegpunkte |
| 4 | 5 Siegpunkte |
| 5 | 6 Siegpunkte |

Erreichen mehrere Spieler das Ziel, gewinnt der mit mehr Siegpunkten. Bei Gleichstand an der Spitze geht es weiter. Wer die erste Runde beginnt, lost die App aus. Danach beginnt, wer in der Vorrunde die meisten Punkte geholt hat. Schlägt der Norden mindestens 2 Gegner, erinnert die App ans Kartenziehen.

### Tischansicht

Das Handy oder Tablet liegt in der Tischmitte, und die oberen Felder sind gedreht, damit jeder seine Zahl lesen kann. Die Plätze gehen im Uhrzeigersinn:

| Spieler | Oben (gedreht) | Unten |
| --- | --- | --- |
| 2 | Spieler 1 | Spieler 2 |
| 3 | Spieler 2 | Spieler 1, Spieler 3 |
| 4 | Spieler 2, Spieler 3 | Spieler 1, Spieler 4 |
| 5 | Spieler 2, Spieler 3 | Spieler 1, Spieler 5, Spieler 4 |

Die Tischansicht lässt sich unter „Einstellungen“ ausschalten.

## Installieren (Android)

1. Die APK aus `release/` auf dem Handy herunterladen.
2. Datei öffnen und die Installation aus dieser Quelle erlauben.
3. Die Warnung von Play Protect („Unbekannte App“) mit „Trotzdem installieren“ bestätigen.

Läuft ab Android 7.

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `apps/fraktionen/` | Gwent Fraktionen: `index.html` (die ganze App), Manifest, Icon, Activity |
| `apps/plus/` | Gwent Plus: wie oben |
| `android/` | Build-Skript, ZIP-Ausrichtung, Signierer |
| `images/` | Kartenbilder der Fraktionen als Quelldateien |
| `release/` | Fertige, signierte APKs |

Jede `index.html` läuft auch direkt im Browser.

## Selbst bauen

```bash
bash android/build.sh            # beide Apps
bash android/build.sh plus       # nur Gwent Plus
bash android/build.sh fraktionen # nur Gwent Fraktionen
```

Das Skript lädt beim ersten Lauf die Werkzeuge herunter (aapt2, android.jar, dx, APK-Signierer). Ein Android SDK oder Gradle brauchst du nicht.

Signiert wird mit dem Schlüssel in `android/keys/`, und dieser Ordner wird nicht committet. Ein Update lässt sich nur über eine installierte App installieren, wenn beide mit demselben Schlüssel signiert sind.

## Hinweis

Gwent und die Fraktionsbilder gehören CD PROJEKT RED. Das hier ist ein inoffizielles Fanprojekt ohne kommerziellen Zweck. Die Regeln für „Alle gegen Alle“ stammen aus der Spielmodi-Regel des Brettspiels.
