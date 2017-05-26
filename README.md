# Faster Command Line Tools in Nim

This is a project to test how Nim compares to D in one very specific scenario. It was inspired by the [`Faster Command line Tools in D` blog post](http://dlang.org/blog/2017/05/24/faster-command-line-tools-in-d/).

There's a full blog post explaining the reasoning and with some basic results form my system [available here](https://www.euantorano.co.uk/posts/faster-command-line-tools-in-nim/).

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