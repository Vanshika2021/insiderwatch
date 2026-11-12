"""Stream d_us_txt.zip -> one CSV on stdout. Drops per-file headers, adds market
(folder name, e.g. "nasdaq stocks") and source_file (file name, e.g. aapl.us.txt). <TICKER> is kept as is. Run with python3 -I."""
import io
import sys
import zipfile

files = rows = empty = 0
out = sys.stdout
out.write("ticker,per,date,time,open,high,low,close,vol,openint,market,source_file\n")
with zipfile.ZipFile(sys.argv[1]) as z:
    for info in z.infolist():
        if not info.filename.endswith(".txt"):
            continue
        if info.file_size == 0:
            empty += 1
            continue
        market = info.filename.split("/")[3]
        src = info.filename.rsplit("/", 1)[-1].replace(",", "_")  # e.g. aapl.us.txt; keep CSV well-formed
        with io.TextIOWrapper(z.open(info), encoding="utf-8") as f:
            next(f, None)  # skip <TICKER>,<PER>,... header
            for line in f:
                line = line.rstrip("\r\n")
                if line:
                    out.write(f"{line},{market},{src}\n")
                    rows += 1
        files += 1
print(f"stooq: {files} files, {rows} rows, {empty} empty files skipped", file=sys.stderr)
