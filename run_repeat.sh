printf "Python..."
./repeat.rb python ./Python/csv_test.py ./ngrams.tsv 1 2

printf "\nD (DMD)..."
./repeat.rb ./D/csv_test ./ngrams.tsv 1 2

printf "\nD (LDC)..."
./repeat.rb ./D/csv_test_ldc ./ngrams.tsv 1 2

printf "\nNim..."
./repeat.rb ./Nim/csv_test ./ngrams.tsv 1 2

printf "\nC..."
./repeat.rb ./C/fast ./ngrams.tsv 1 2

printf "\nGo..."
./repeat.rb ./Go/csvtest ./ngrams.tsv 1 2
