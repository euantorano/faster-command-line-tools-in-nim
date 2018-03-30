# Faster Command Line Tools in Nim

This is a project to test how Nim compares to D in one very specific scenario. It was inspired by the [`Faster Command line Tools in D` blog post](http://dlang.org/blog/2017/05/24/faster-command-line-tools-in-d/).

There's a full blog post explaining the reasoning and with some basic results form my system [available here](https://www.euantorano.co.uk/posts/faster-command-line-tools-in-nim/).

## Running the tests

All versions are built and ran using Docker.

To run every version and dump results into the `output` folder, you can use the `run` Make target:

```
make run
```

This will also create a file `output/results.txt` which is a combination of all other results in a single file.

You can also run individual targets if you're working on improving a target:

- **C**: `make c_run`
- **D**: `make d_run`
- **Go**: `make go_run`
- **Nim**: `make nim_run`
- **Python**: `make python_run`

This will download the `resources/ngrams.tsv` if it doesn't already exist

## TODO

- [ ] Run each version multiple times and take the average run times
- [ ] Format the results into a nice table in the `output` directory when using `make run`, and possibly add graphs