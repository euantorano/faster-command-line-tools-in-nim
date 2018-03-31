import std.algorithm, std.conv, std.file, std.stdio;
import fastcsv;

const delim = '\t';

int main(string[] args) {
    if (args.length < 4) {
        writeln("synopsis: ", args[0], " filename keyfield valuefield");
        return 1;
    }

    const filename        = args[1],
          keyFieldIndex   = args[2].to!size_t,
          valueFieldIndex = args[3].to!size_t,
          maxFieldIndex   = max(keyFieldIndex, valueFieldIndex);
    const file = cast(string) read(filename);
    long[string] sumByKey;

    foreach(record; file.csvByRecord!(delim)) {
        if (record.length > maxFieldIndex)
            sumByKey[record[keyFieldIndex]] += record[valueFieldIndex].to!long;
    }

    if (sumByKey.length == 0) {
        writeln("No entries");
    }
    else {
        const maxEntry = sumByKey.byKeyValue.maxElement!"a.value";
        writeln("max_key: ", maxEntry.key, " sum: ", maxEntry.value);
    }

    return 0;
}
