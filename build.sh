echo "Building with DMD..."
rm D/{csv_test,csv_test_ldc,*.o}
dmd -O -release -inline -boundscheck=off -of=./D/csv_test ./D/csv_test.d

printf "\nBuilding with LDC..."
ldc2 -of=./D/csv_test_ldc -O -release -boundscheck=off ./D/csv_test.d

printf "\nBuilding with Nim"
rm Nim/csv_test
rm -Rf Nim/nimcache
nim c -d:release -o:./Nim/csv_test ./Nim/csv_test.nim

printf "\nBuilding with C"
rm C/fast
make -C C/

printf "\nBuilding with Go"
rm Go/csvtest
go build -ldflags "-s -w" -o Go/csvtest Go/csvtest.go 