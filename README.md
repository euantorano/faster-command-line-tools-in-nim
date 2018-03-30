# Faster Command Line Tools in Nim

This is a project to test how Nim compares to D in one very specific scenario. It was inspired by the [`Faster Command line Tools in D` blog post](http://dlang.org/blog/2017/05/24/faster-command-line-tools-in-d/).

There's a full blog post explaining the reasoning and with some basic results form my system [available here](https://www.euantorano.co.uk/posts/faster-command-line-tools-in-nim/).

## Running the tests

All versions are built and ran using Docker.

To run every version and dump results into the `output` folder, you can use the `run` Make target:

```
make run
```

You can also run individual targets if you're working on improving a target:

- **C**: `make c_run`
- **D**: `make d_run`
- **Go**: `make go_run`
- **Nim**: `make nim_run`
- **Python**: `make python_run`

This will download the `resources/ngrams.tsv` if it doesn't already exist

## Results

This repository is built by Travis for every push or PR. Results are published to the `gh-pages` branch:

- [C (GCC)](https://euantorano.github.io/faster-command-line-tools-in-nim/c_gcc.txt)
- [C (clang)](https://euantorano.github.io/faster-command-line-tools-in-nim/c_clang.txt)
- [D (DMD)](https://euantorano.github.io/faster-command-line-tools-in-nim/d_dmd.txt)
- [D (LDC)](https://euantorano.github.io/faster-command-line-tools-in-nim/d_ldc.txt)
- [Go](https://euantorano.github.io/faster-command-line-tools-in-nim/go.txt)
- [Nim](https://euantorano.github.io/faster-command-line-tools-in-nim/nim.txt)
- [Python 2](https://euantorano.github.io/faster-command-line-tools-in-nim/python2.txt)
- [Python 3](https://euantorano.github.io/faster-command-line-tools-in-nim/python3.txt)

## TODO

- [ ] Build an overall results file which will be published to GitHub pages - possibly include graphs in this file?
- [ ] Run each version multiple times and take the average run times
