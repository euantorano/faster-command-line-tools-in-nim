int main(string[] args)
{
    import std.algorithm : max, maxElement, splitter;
    import std.array : appender;
    import std.conv : to;
    import std.range : take;
    import std.stdio;

    if (args.length < 4)
    {
        writefln ("synopsis: %s filename keyfield valuefield", args[0]);
        return 1;
    }

    string filename = args[1];
    size_t keyFieldIndex = args[2].to!size_t;
    size_t valueFieldIndex = args[3].to!size_t;
    size_t maxFieldIndex = max(keyFieldIndex, valueFieldIndex);
    string delim = "\t";

    long[string] sumByKey;
    auto fields = appender!(char[][])();

    foreach(line; filename.File.byLine)
    {
        fields.clear;
        fields.put(line.splitter(delim).take(maxFieldIndex + 1));
        if (maxFieldIndex < fields.data.length)
        {
            char[] key = fields.data[keyFieldIndex];
            long fieldValue = fields.data[valueFieldIndex].to!long;

            if (auto sumValuePtr = key in sumByKey) *sumValuePtr += fieldValue;
            else sumByKey[key.to!string] = fieldValue;
        }
    }

    if (sumByKey.length == 0) writeln("No entries");
    else
    {
        auto maxEntry = sumByKey.byKeyValue.maxElement!"a.value";
        writeln("max_key: ", maxEntry.key, " sum: ", maxEntry.value);
    }
    return 0;
}