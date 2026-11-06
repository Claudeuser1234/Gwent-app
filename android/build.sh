#!/usr/bin/env bash
# Baut release/Gwent-Fraktionen.apk ohne Android Studio.
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
BUILD="$HERE/build"
KEYS="$HERE/keys"
mkdir -p "$TOOLS" "$KEYS"

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
rm -rf "$BUILD"; mkdir -p "$BUILD/compiled" "$BUILD/classes" "$BUILD/assets"
cp "$ROOT/web/index.html" "$BUILD/assets/index.html"

"$TOOLS/aapt2" compile --dir "$HERE/res" -o "$BUILD/compiled/"
"$TOOLS/aapt2" link -I "$TOOLS/android.jar" --manifest "$HERE/AndroidManifest.xml" \
  -A "$BUILD/assets" -o "$BUILD/base.apk" "$BUILD"/compiled/*.flat

javac --release 8 -nowarn -cp "$TOOLS/android.jar" -d "$BUILD/classes" $(find "$HERE/src" -name '*.java')
(cd "$BUILD/classes" && jar cf ../classes.jar .)
sh "$TOOLS/dex-tools/d2j-jar2dex.sh" -f -o "$BUILD/classes.dex" "$BUILD/classes.jar" >/dev/null

python3 "$HERE/align.py" "$BUILD/base.apk" "$BUILD/classes.dex" "$BUILD/unsigned.apk"
mkdir -p "$ROOT/release"
node "$TOOLS/sign.mjs" "$BUILD/unsigned.apk" "$ROOT/release/Gwent-Fraktionen.apk" "$KEYS/key.pem" "$KEYS/cert.pem"
echo "Fertig: release/Gwent-Fraktionen.apk"
