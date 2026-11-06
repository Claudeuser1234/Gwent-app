"""Baut das unsignierte APK: Eintraege aus aapt2 plus classes.dex.

resources.arsc und das Icon werden unkomprimiert und 4-Byte-ausgerichtet
abgelegt (Pflicht ab targetSdk 30), alles andere wird komprimiert.
Aufruf: python3 align.py base.apk classes.dex unsigned.apk
"""
import sys
import zipfile

base, dex, out = sys.argv[1:4]
src = zipfile.ZipFile(base)
items = [(n, src.read(n)) for n in src.namelist()]
items.insert(1, ("classes.dex", open(dex, "rb").read()))

with open(out, "wb") as fh:
    z = zipfile.ZipFile(fh, "w")
    for name, data in items:
        zi = zipfile.ZipInfo(name, date_time=(1981, 1, 1, 0, 0, 0))
        if name == "resources.arsc" or name.endswith(".png"):
            zi.compress_type = zipfile.ZIP_STORED
            offset = fh.tell() + 30 + len(name.encode())
            zi.extra = b"\x00" * ((-offset) % 4)
        else:
            zi.compress_type = zipfile.ZIP_DEFLATED
        z.writestr(zi, data)
    z.close()
