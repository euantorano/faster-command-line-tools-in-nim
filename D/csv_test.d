int main(string[] args)
{
    import std.algorithm : max, maxElement, splitter;
    import std.conv : to;
    import std.range : enumerate;
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

    foreach(line; filename.File.byLine)
    {
        char[] key;
        long value;
        bool allFound = false;

        foreach (i, field; line.splitter(delim).enumerate)
        {
            if (i == keyFieldIndex) key = field;
            if (i == valueFieldIndex) value = field.to!long;
            if (i == maxFieldIndex)
            {
                allFound = true;
                break;
            }
        }

        if (allFound)
        {
            if (auto sumValuePtr = key in sumByKey) *sumValuePtr += value;
            else sumByKey[key.to!string] = value;
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