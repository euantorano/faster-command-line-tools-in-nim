# Faster Command Line Tools in Nim

This is a project to test how Nim compares to D in one very specific scenario. It was inspired by the [`Faster Command line Tools in D` blog post](http://dlang.org/blog/2017/05/24/faster-command-line-tools-in-d/).

## Building

The D code is built using both DMD (the reference D compiler) and LDC (the LLVM based D compiler which emits faster code in most scenarios).

The Nim code is built using the standard Nim compiler, in release mode.

The build commands for each scenario can be found below. All of these commands can be ran uing the `build.sh` script.

### D (DMD)

`dmd -O -release -inline -boundscheck=off -of=./D/csv_test ./D/csv_test.d`

### D (LDC)

`ldc2 -of=./D/csv_test_ldc -O -release -boundscheck=off ./D/csv_test.d`

### Nim

`nim c -d:release -o:./Nim/csv_test ./Nim/csv_test.nim`

## Running

Before running, be sure to grab the data source from the Google Books project, which can be [found here](https://storage.googleapis.com/books/ngrams/books/googlebooks-eng-all-1gram-20120701-0.gz). This should be extracted to a file named `ngrams.tsv`.

All of the implementations should produce the same output, which should read as follows:

```
max_key: 2006 sum: 22569013
```

You can run all of the implementations, with timing results using the `run.sh` script.

For true benchmarks, this should be ran multiple times and an average calculated.

## Test Results

These results are from a single run on a mid 2014 MacBook Pro with a 2.8GHz Intel Core i7. The results shown below are taken straight from the output of the `run.sh` script.

```
Python...
max_key: 2006 sum: 22569013

real	0m14.769s
user	0m14.627s
sys	0m0.106s

D (DMD)...
max_key: 2006 sum: 22569013

real	0m2.458s
user	0m2.407s
sys	0m0.049s

D (LDC)...
max_key: 2006 sum: 22569013

real	0m1.329s
user	0m1.279s
sys	0m0.048s

Nim...
max_key: 2006 sum: 22569013

real	0m1.182s
user	0m1.140s
sys	0m0.040s
```