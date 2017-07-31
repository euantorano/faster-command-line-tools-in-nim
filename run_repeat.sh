echo "Python..."
./repeat.rb python ./Python/csv_test.py ./ngrams.tsv 1 2

echo "\nD (DMD)..."
./repeat.rb ./D/csv_test ./ngrams.tsv 1 2

echo "\nD (LDC)..."
./repeat.rb ./D/csv_test_ldc ./ngrams.tsv 1 2

echo "\nNim..."
./repeat.rb ./Nim/csv_test ./ngrams.tsv 1 2

echo "\nC..."
./repeat.rb ./C/fast ./ngrams.tsv 1 2