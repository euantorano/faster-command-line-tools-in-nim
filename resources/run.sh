#!/usr/bin/env bash
( time /app/csv_test /data/ngrams.tsv 1 2 ) > /output/$1 2>&1