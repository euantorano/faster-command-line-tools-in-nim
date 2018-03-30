#!/usr/bin/env bash
( time python /app/csv_test.py /data/ngrams.tsv 1 2 ) > /output/$1 2>&1