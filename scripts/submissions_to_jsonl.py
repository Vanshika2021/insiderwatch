"""Stream submissions.zip -> JSON Lines on stdout (one compact object per line, plus "_file"). Run with python3 -I."""
import json
import sys
import zipfile

ok = bad = 0
with zipfile.ZipFile(sys.argv[1]) as z:
    for name in z.namelist():
        if name.endswith("/"):
            continue
        try:
            obj = json.loads(z.read(name))
        except ValueError as e:
            bad += 1
            print(f"BAD {name}: {e}", file=sys.stderr)
            continue
        if not isinstance(obj, dict):
            obj = {"data": obj}
        obj["_file"] = name
        sys.stdout.write(json.dumps(obj, separators=(",", ":"), ensure_ascii=False) + "\n")
        ok += 1
print(f"submissions: wrote {ok} lines, skipped {bad} bad files", file=sys.stderr)
