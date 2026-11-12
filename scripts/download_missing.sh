#!/usr/bin/env bash
# Download only missing InsiderWatch files into ~/sec_zips. One request at a time + 0.2s sleep (<= 5 req/s).
set -u
UA="NYU CS-GY6513 va2652@nyu.edu"
D=~/sec_zips; LOG=$D/download.log
mkdir -p "$D"

is_good() {  # file exists, non-empty, not an HTML error page, and (if zip) passes unzip -tq
  [ -s "$1" ] || return 1
  head -c 512 "$1" | grep -qiE '<html|<!doctype' && return 1
  [[ "$1" == *.zip ]] && { unzip -tq "$1" >/dev/null 2>&1 || return 1; }
  return 0
}

get() {
  local url=$1 out=$D/$2
  if is_good "$out"; then echo "SKIP  $2" | tee -a "$LOG"; return; fi
  curl -sS -f -L --retry 3 --retry-delay 10 --compressed -A "$UA" -o "$out.part" "$url"
  local rc=$?
  sleep 0.2
  if [ $rc -eq 0 ] && mv "$out.part" "$out" && is_good "$out"; then
    echo "OK    $2 $(stat -c %s "$out")" | tee -a "$LOG"
  else
    [ -e "$out" ] && mv "$out" "$out.bad"; rm -f "$out.part"
    echo "FAIL  $2 (curl rc=$rc) $url" | tee -a "$LOG"
  fi
}

for y in $(seq 2015 2025); do for q in 1 2 3 4; do
  get "https://www.sec.gov/files/structureddata/data/insider-transactions-data-sets/${y}q${q}_form345.zip" "${y}q${q}_form345.zip"
  get "https://www.sec.gov/Archives/edgar/full-index/${y}/QTR${q}/form.idx" "form_${y}_QTR${q}.idx"
done; done
get "https://www.sec.gov/files/company_tickers.json" "company_tickers.json"
get "https://www.sec.gov/Archives/edgar/daily-index/bulkdata/submissions.zip" "submissions.zip"

echo "== summary"; grep -c '^OK' "$LOG"; grep '^FAIL' "$LOG" || echo "no failures"
du -ch "$D"/*form345.zip | tail -1; du -ch "$D"/form_*.idx | tail -1; ls -l "$D"/submissions.zip "$D"/company_tickers.json
