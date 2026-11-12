#!/usr/bin/env bash
# Load InsiderWatch raw data into HDFS. Run on master inside tmux, after download_missing.sh succeeds.
set -euo pipefail
D=~/sec_zips; S=~/iw_scripts; R=/user/va2652_nyu_edu/insider/raw

echo "== quota BEFORE"; hdfs dfs -count -q -h /user/va2652_nyu_edu

hdfs dfs -mkdir -p $R/zips $R/form345 $R/form345_docs $R/form_idx $R/submissions $R/stooq $R/tickers

# 1. original zips (44 form345 + submissions + stooq)
hdfs dfs -put -f "$D"/*_form345.zip "$D"/submissions.zip "$D"/d_us_txt.zip $R/zips/

# 2. form345: 8 TSVs per quarter in form345/<qtr>/, metadata .json + readme .htm in form345_docs/<qtr>/
for z in "$D"/*_form345.zip; do
  qtr=$(basename "$z" _form345.zip)
  t=$(mktemp -d); unzip -q "$z" -d "$t"
  ntsv=$(find "$t" -maxdepth 1 -type f -name '*.tsv' | wc -l)
  nother=$(find "$t" -type f ! -name '*.tsv' | wc -l)
  echo "$qtr: $ntsv tsv, $nother docs"
  [ "$ntsv" -eq 8 ] || { echo "ERROR $qtr: expected 8 TSVs"; exit 1; }
  hdfs dfs -mkdir -p $R/form345/$qtr $R/form345_docs/$qtr
  hdfs dfs -put -f "$t"/*.tsv $R/form345/$qtr/
  find "$t" -type f ! -name '*.tsv' -print0 | xargs -0 -I{} hdfs dfs -put -f {} $R/form345_docs/$qtr/
  rm -rf "$t"
done

# 3. form.idx + tickers
hdfs dfs -put -f "$D"/form_*_QTR*.idx $R/form_idx/
hdfs dfs -put -f "$D"/company_tickers.json $R/tickers/

# 4. submissions -> ONE JSONL file, streamed (never extracted to disk)
python3 -I $S/submissions_to_jsonl.py "$D"/submissions.zip | hdfs dfs -put -f - $R/submissions/submissions.jsonl

# 5. stooq -> ONE CSV, streamed
python3 -I $S/stooq_combine.py "$D"/d_us_txt.zip | hdfs dfs -put -f - $R/stooq/stooq_us_daily.csv

echo "== quota AFTER"; hdfs dfs -count -q -h /user/va2652_nyu_edu
echo "== du per raw subfolder"; hdfs dfs -du -s -h $R/*
echo "== form345 file count: $(hdfs dfs -count $R/form345 | awk '{print $2}')  docs: $(hdfs dfs -count $R/form345_docs | awk '{print $2}')"
echo "== submissions lines:  $(hdfs dfs -cat $R/submissions/submissions.jsonl | wc -l)"
echo "LOAD_COMPLETE"
