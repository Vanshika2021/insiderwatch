# InsiderWatch

InsiderWatch is a CS-GY 6513 (Big Data) course project that surveils insider trading using only public SEC data. It joins SEC Form 3/4/5 insider-transaction data sets, EDGAR quarterly form indexes and bulk company submissions with Stooq daily US prices and the SEC CIK-to-ticker map, covering 2015–2025 (44 quarters). It runs on NYU's Dataproc cluster with HDFS, Spark and Kafka.

## HDFS layout

All raw data lives under `/user/va2652_nyu_edu/insider/raw/`:

| Path | Contents |
|---|---|
| `zips/` | Original downloads: 44 `YYYYqN_form345.zip`, `submissions.zip`, `d_us_txt.zip` |
| `form345/<YYYYqN>/` | 8 TSVs per quarter: `SUBMISSION`, `REPORTINGOWNER`, `NONDERIV_TRANS`, `NONDERIV_HOLDING`, `DERIV_TRANS`, `DERIV_HOLDING`, `FOOTNOTES`, `OWNER_SIGNATURE` |
| `form345_docs/<YYYYqN>/` | SEC metadata `.json` and readme `.htm` for each quarter (kept apart so `form345/*/*.tsv` globs see only TSVs) |
| `form_idx/` | 44 EDGAR full-index files, `form_YYYY_QTRn.idx` |
| `submissions/submissions.jsonl` | All EDGAR submissions JSON files as one JSON Lines file (one compact object per line, plus a `_file` field with the source file name) |
| `stooq/stooq_us_daily.csv` | All Stooq US daily price files combined. Stooq's `<TICKER>` column is kept as is, with `market` (e.g. `nasdaq stocks`) and `source_file` (e.g. `aapl.us.txt`) added |
| `tickers/company_tickers.json` | SEC CIK-to-ticker map |

## Scripts

- `scripts/download_missing.sh`: downloads any missing source files into `~/sec_zips`. It identifies itself to SEC with a User-Agent header and stays under 10 requests per second.
- `scripts/load_hdfs.sh`: loads `~/sec_zips` into the HDFS layout above (run it inside tmux).
- `scripts/submissions_to_jsonl.py`: streams `submissions.zip` into JSON Lines. It is used by `load_hdfs.sh`.
- `scripts/stooq_combine.py`: streams `d_us_txt.zip` into one CSV. It is used by `load_hdfs.sh`.
