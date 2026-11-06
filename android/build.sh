#!/usr/bin/env bash
# Baut die Android-Apps ohne Android Studio.
#
#   bash android/build.sh            # beide Apps
#   bash android/build.sh fraktionen # nur Gwent Fraktionen
#   bash android/build.sh plus       # nur Gwent Plus
#
# Braucht: bash, curl, unzip, python3, Java (JDK 11+), Node.js 18+, openssl.
# Die Werkzeuge (aapt2, android.jar, dx, APK-Signierer) werden beim ersten Lauf
# nach android/.tools geladen.
#
# Signierschluessel: android/keys/key.pem + cert.pem. Fehlen sie, wird ein neuer
# Schluessel erzeugt. Fuer Updates einer installierten App immer denselben
# Schluessel verwenden. Den Ordner keys/ nie committen.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$HERE")"
TOOLS="$HERE/.tools"
KEYS="$HERE/keys"
mkdir -p "$TOOLS" "$KEYS"

declare -A APK_NAME=( [fraktionen]="Gwent-Fraktionen.apk" [plus]="Gwent-Plus.apk" )
APPS=("${@:-fraktionen plus}")
APPS=(${APPS[@]})

# --- Werkzeuge -----------------------------------------------------------
if [ ! -f "$TOOLS/android.jar" ]; then
  curl -fsSL -o "$TOOLS/android.jar" \
    https://raw.githubusercontent.com/Sable/android-platforms/master/android-30/android.jar
fi
if [ ! -x "$TOOLS/aapt2" ]; then
  (cd "$TOOLS" && npm pack aaptjs3@2.0.2 --silent >/dev/null \
    && tar xzf aaptjs3-2.0.2.tgz package/bin/x64/linux/aapt2 \
    && mv package/bin/x64/linux/aapt2 aapt2 && rm -rf package aaptjs3-2.0.2.tgz)
  chmod +x "$TOOLS/aapt2"
fi
if [ ! -d "$TOOLS/dex-tools" ]; then
  curl -fsSL -o "$TOOLS/d2j.zip" \
    https://github.com/pxb1988/dex2jar/releases/download/v2.4/dex-tools-v2.4.zip
  unzip -q "$TOOLS/d2j.zip" -d "$TOOLS" && mv "$TOOLS"/dex-tools-v2.4 "$TOOLS/dex-tools" && rm "$TOOLS/d2j.zip"
fi
if [ ! -d "$TOOLS/node_modules/apk_sign_ts" ]; then
  [ -f "$TOOLS/package.json" ] || echo '{"name":"gwent-build-tools","private":true}' > "$TOOLS/package.json"
  (cd "$TOOLS" && npm i apk_sign_ts@1.0.1 --silent)
fi
cp "$HERE/sign.mjs" "$TOOLS/sign.mjs"

if [ ! -f "$KEYS/key.pem" ]; then
  openssl req -x509 -newkey rsa:2048 -nodes -keyout "$KEYS/key.pem" -out "$KEYS/cert.pem" \
    -days 10000 -subj "/CN=Gwent Fraktionen" 2>/dev/null
  echo "Neuer Signierschluessel in android/keys/ erzeugt."
fi

# --- Build ---------------------------------------------------------------
build_app() {
  local app="$1" src="$ROOT/apps/$1" build="$HERE/build/$1"
  [ -d "$src" ] || { echo "Unbekannte App: $app (fraktionen oder plus)"; exit 1; }
  rm -rf "$build"; mkdir -p "$build/compiled" "$build/classes" "$build/assets"
  cp "$src/index.html" "$build/assets/index.html"

  "$TOOLS/aapt2" compile --dir "$src/res" -o "$build/compiled/"
  "$TOOLS/aapt2" link -I "$TOOLS/android.jar" --manifest "$src/AndroidManifest.xml" \
    -A "$build/assets" -o "$build/base.apk" "$build"/compiled/*.flat

  javac --release 8 -nowarn -cp "$TOOLS/android.jar" -d "$build/classes" $(find "$src/src" -name '*.java')
  (cd "$build/classes" && jar cf ../classes.jar .)
  sh "$TOOLS/dex-tools/d2j-jar2dex.sh" -f -o "$build/classes.dex" "$build/classes.jar" >/dev/null

  python3 "$HERE/align.py" "$build/base.apk" "$build/classes.dex" "$build/unsigned.apk"
  mkdir -p "$ROOT/release"
  node "$TOOLS/sign.mjs" "$build/unsigned.apk" "$ROOT/release/${APK_NAME[$app]}" "$KEYS/key.pem" "$KEYS/cert.pem" >/dev/null
  echo "Fertig: release/${APK_NAME[$app]}"
}

for app in "${APPS[@]}"; do build_app "$app"; done
