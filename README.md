# Gwent Fraktionen

Zufallsgenerator für die fünf klassischen Gwent-Fraktionen: Königreiche des Nordens, Nilfgaard, Scoia'tael, Monster und Skellige. Für 1 bis 5 Spieler.

- **1–5 Spieler:** Jeder bekommt eine eigene Karte.
- **Jede Fraktion nur einmal:** Ein- oder ausschaltbar.
- **Topf:** Einzelne Fraktionen lassen sich aus der Ziehung nehmen.
- **Verlauf:** Zeigt die letzten Ziehungen und bleibt nach dem Schließen erhalten.
- **Offline:** Schriften und Bilder sind eingebettet.

## Installieren (Android)

1. `release/Gwent-Fraktionen.apk` auf dem Handy herunterladen.
2. Datei öffnen und die Installation aus dieser Quelle erlauben.
3. Die Warnung von Play Protect („Unbekannte App“) mit „Trotzdem installieren“ bestätigen.

Läuft ab Android 7.

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `web/index.html` | Die komplette App als eine HTML-Datei. Läuft auch direkt im Browser oder über GitHub Pages. |
| `android/` | Android-Hülle: eine Activity mit WebView, die `web/index.html` lädt |
| `images/` | Die Kartenbilder der Fraktionen als Quelldateien |
| `release/` | Die fertige, signierte APK |

## Selbst bauen

```bash
bash android/build.sh
```

Das Skript lädt beim ersten Lauf die Werkzeuge herunter (aapt2, android.jar, dx, APK-Signierer) und schreibt `release/Gwent-Fraktionen.apk`. Ein Android SDK oder Gradle brauchst du nicht.

Signiert wird mit dem Schlüssel in `android/keys/`, und dieser Ordner wird nicht committet. Ein Update lässt sich nur über eine installierte App installieren, wenn beide mit demselben Schlüssel signiert sind. Bei einem neuen Schlüssel musst du die alte App vorher deinstallieren.

## Hinweis

Gwent und die Fraktionsbilder gehören CD PROJEKT RED. Das hier ist ein inoffizielles Fanprojekt ohne kommerziellen Zweck.
