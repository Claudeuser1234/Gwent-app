import { signApk } from 'apk_sign_ts';
import fs from 'fs';
const [,, inp, out, key, cert] = process.argv;
const r = await signApk(new Uint8Array(fs.readFileSync(inp)), fs.readFileSync(key,'utf8'), fs.readFileSync(cert,'utf8'));
fs.writeFileSync(out, r.signedApk); console.log('signed', r.signedApk.length);
