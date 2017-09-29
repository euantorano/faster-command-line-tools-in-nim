echo "Python..."
time python2 ./Python/csv_test.py ./ngrams.tsv 1 2


printf "\nD (DMD)..."
time ./D/csv_test ./ngrams.tsv 1 2

printf "\nD (LDC)..."
time ./D/csv_test_ldc ./ngrams.tsv 1 2

printf "\nNim..."
time ./Nim/csv_test ./ngrams.tsv 1 2

printf "\nC..."
time ./C/fast ./ngrams.tsv 1 2

printf "\nGo..."
time ./Go/csvtest ./ngrams.tsv 1 2
