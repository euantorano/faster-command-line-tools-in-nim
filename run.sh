echo "Python..."

time python ./Python/csv_test.py ./ngrams.tsv 1 2

echo "\nD (DMD)..."

time ./D/csv_test ./ngrams.tsv 1 2

echo "\nD (LDC)..."

time ./D/csv_test_ldc ./ngrams.tsv 1 2

echo "\nNim..."

time ./Nim/csv_test ./ngrams.tsv 1 2