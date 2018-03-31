/**
 * Experimental fast CSV reader.
 *
 * Based on RFC 4180.
 */
module fastcsv;

/**
 * Reads CSV data from the given filename.
 */
auto csvFromUtf8File(string filename)
{
    import std.file : read;
    return csvToArray(cast(string) read(filename));
}

private char[] filterQuotes(dchar quote)(const(char)[] str) pure
{
    auto buf = new char[str.length];
    size_t j = 0;
    for (size_t i = 0; i < str.length; i++)
    {
        if (str[i] == quote)
        {
            buf[j++] = '"';
            i++;

            if (i >= str.length)
                break;

            if (str[i] == quote)
                continue;
        }
        buf[j++] = str[i];
    }
    return buf[0 .. j];
}

/**
 * Parse CSV data into an input range of records.
 *
 * Params:
 *  fieldDelim = The field delimiter (default: ',')
 *  quote = The quote character (default: '"')
 *  input = The data in CSV format.
 *
 * Returns:
 *  An input range of records, each of which is an array of fields.
 *
 * Bugs:
 *  Does not do any validation on the input; will produce nonsensical results
 *  if input is malformed.
 *
 *  Cannot handle records with more than 4096 fields each. (This limit can be
 *  statically increased by increasing fieldBlockSize.)
 */
auto csvByRecord(dchar fieldDelim=',', dchar quote='"')(const(char)[] input)
{
    struct Result
    {
        private enum fieldBlockSize = 1 << 16;
        private const(char)[] data;
        private const(char)[][] fields;
        private size_t i, curField;

        bool empty = true;
        const(char)[][] front;

        this(const(char)[] input)
        {
            data = input;
            fields = new const(char)[][fieldBlockSize];
            i = 0;
            curField = 0;
            empty = (input.length == 0);
            parseNextRecord();
        }

        void parseNextRecord()
        {
            size_t firstField = curField;
            while (i < data.length && data[i] != '\n' && data[i] != '\r')
            {
                // Parse fields
                size_t firstChar, lastChar;
                bool hasDoubledQuotes = false;

                if (data[i] == quote)
                {
                    import std.algorithm : max;

                    i++;
                    firstChar = i;
                    while (i < data.length)
                    {
                        if (data[i] == quote)
                        {
                            i++;
                            if (i >= data.length || data[i] != quote)
                                break;

                            hasDoubledQuotes = true;
                        }
                        i++;
                    }
                    assert(i-1 < data.length);
                    lastChar = max(firstChar, i-1);
                }
                else
                {
                    firstChar = i;
                    while (i < data.length && data[i] != fieldDelim &&
                           data[i] != '\n' && data[i] != '\r')
                    {
                        i++;
                    }
                    lastChar = i;
                }
                if (curField >= fields.length)
                {
                    // Fields block is full; copy current record fields into
                    // new block so that they are contiguous.
                    auto nextFields = new const(char)[][fieldBlockSize];
                    nextFields[0 .. curField - firstField] =
                        fields[firstField .. curField];

                    //fields.length = firstField; // release unused memory?

                    curField = curField - firstField;
                    firstField = 0;
                    fields = nextFields;
                }
                assert(curField < fields.length);
                if (hasDoubledQuotes)
                    fields[curField++] = filterQuotes!quote(
                                            data[firstChar .. lastChar]);
                else
                    fields[curField++] = data[firstChar .. lastChar];

                // Skip over field delimiter
                if (i < data.length && data[i] == fieldDelim)
                    i++;
            }

            front = fields[firstField .. curField];

            // Skip over record delimiter(s)
            while (i < data.length && (data[i] == '\n' || data[i] == '\r'))
                i++;
        }

        void popFront()
        {
            if (i >= data.length)
            {
                empty = true;
                front = [];
            }
            else
                parseNextRecord();
        }
    }
    return Result(input);
}

/**
 * Parses CSV string data into an array of records.
 *
 * Params:
 *  fieldDelim = The field delimiter (default: ',')
 *  quote = The quote character (default: '"')
 *  input = The data in CSV format.
 *
 * Returns:
 *  An array of records, each of which is an array of fields.
 */
auto csvToArray(dchar fieldDelim=',', dchar quote='"')(const(char)[] input)
{
    import core.memory : GC;
    import std.array : array;

    GC.disable();
    auto result = input.csvByRecord!(fieldDelim, quote).array;
    GC.collect();
    GC.enable();
    return result;
}

unittest
{
    auto sampleData =
        `123,abc,"mno pqr",0` ~ "\n" ~
        `456,def,"stuv wx",1` ~ "\n" ~
        `78,ghijk,"yx",2`;

    auto parsed = csvToArray(sampleData);
    assert(parsed == [
        [ "123", "abc", "mno pqr", "0" ],
        [ "456", "def", "stuv wx", "1" ],
        [ "78", "ghijk", "yx", "2" ]
    ]);
}

unittest
{
    auto dosData =
        `123,aa,bb,cc` ~ "\r\n" ~
        `456,dd,ee,ff` ~ "\r\n" ~
        `789,gg,hh,ii` ~ "\r\n";

    auto parsed = csvToArray(dosData);
    assert(parsed == [
        [ "123", "aa", "bb", "cc" ],
        [ "456", "dd", "ee", "ff" ],
        [ "789", "gg", "hh", "ii" ]
    ]);
}

unittest
{
    // Quoted fields that contains newlines and delimiters
    auto nastyData =
        `123,abc,"ha ha ` ~ "\n" ~
        `ha this is a split value",567` ~ "\n" ~
        `321,"a,comma,b",def,111` ~ "\n";

    auto parsed = csvToArray(nastyData);
    assert(parsed == [
        [ "123", "abc", "ha ha \nha this is a split value", "567" ],
        [ "321", "a,comma,b", "def", "111" ]
    ]);
}

unittest
{
    // Quoted fields that contain quotes
    // (Note: RFC-4180 does not allow doubled quotes in unquoted fields)
    auto nastyData =
        `123,"a b ""haha"" c",456` ~ "\n";

    auto parsed = csvToArray(nastyData);
    assert(parsed == [
        [ "123", `a b "haha" c`, "456" ]
    ]);
}

// Boundary condition checks
unittest
{
    auto badData = `123,345,"def""`;
    auto parsed = csvToArray(badData);   // should not crash

    auto moreBadData = `123,345,"a"`;
    parsed = csvToArray(moreBadData);    // should not crash

    auto yetMoreBadData = `123,345,"`;
    parsed = csvToArray(yetMoreBadData); // should not crash

    auto emptyField = `123,,456`;
    parsed = csvToArray(emptyField);
    assert(parsed == [ [ "123", "", "456" ] ]);
}

static if (__VERSION__ < 2067UL)
{
    // Copied from std.traits, to fill up lack in older versions of Phobos
    import std.typetuple : staticMap;
    private enum NameOf(alias T) = T.stringof;
    template isNested(T)
        if(is(T == class) || is(T == struct) || is(T == union))
    {
        enum isNested = __traits(isNested, T);
    }
    template FieldNameTuple(T)
    {
        static if (is(T == struct) || is(T == union))
            alias FieldNameTuple = staticMap!(NameOf, T.tupleof[0 .. $ - isNested!T]);
        else static if (is(T == class))
            alias FieldNameTuple = staticMap!(NameOf, T.tupleof);
        else
            alias FieldNameTuple = TypeTuple!"";
    }
}

/**
 * Transcribe CSV data into an array of structs.
 *
 * Params:
 *  S = The type of the struct each record must conform to.
 *  fieldDelim = The field delimiter (default: ',')
 *  quote = The quote character (default: '"')
 *  input = The data in CSV format.
 *
 * Returns:
 *  An array of S.
 *
 * Bugs:
 *  Cannot handle strings larger than 64KB each. (This limit can be statically
 *  raised by increasing stringBufSize.)
 */
auto csvByStruct(S, dchar fieldDelim=',', dchar quote='"')(const(char)[] input)
    if (is(S == struct))
{
    struct Result
    {
        private enum stringBufSize = 1 << 16;
        private const(char)[] data;
        private char[] stringBuf;
        private size_t i, curStringIdx;

        bool empty = true;
        S front;

        this(const(char)[] input)
        {
            data = input;
            stringBuf = new char[stringBufSize];
            i = 0;
            curStringIdx = 0;

            if (input.length > 0)
            {
                empty = false;
                parseHeader();
                if (input.length > 0)
                    parseNextRecord();
            }
        }

        const(char)[] parseField() pure
        {
            size_t firstChar, lastChar;
            bool hasDoubledQuotes = false;

            if (data[i] == quote)
            {
                import std.algorithm : max;

                i++;
                firstChar = i;
                while (i < data.length)
                {
                    if (data[i] == quote)
                    {
                        i++;
                        if (i >= data.length || data[i] != quote)
                            break;

                        hasDoubledQuotes = true;
                    }
                    i++;
                }
                assert(i-1 < data.length);
                lastChar = max(firstChar, i-1);
            }
            else
            {
                firstChar = i;
                while (i < data.length && data[i] != fieldDelim &&
                       data[i] != '\n' && data[i] != '\r')
                {
                    i++;
                }
                lastChar = i;
            }
            return (hasDoubledQuotes) ?
                filterQuotes!quote(data[firstChar .. lastChar]) :
                data[firstChar .. lastChar];
        }

        void parseHeader()
        {
            static if (__VERSION__ >= 2067UL)
                import std.traits : FieldNameTuple;

            assert(i < data.length);
            foreach (field; FieldNameTuple!S)
            {
                if (parseField() != field)
                    throw new Exception(
                        "CSV fields do not match struct fields");

                // Skip over field delimiter
                if (i < data.length && data[i] == fieldDelim)
                    i++;
            }

            if (i < data.length && data[i] != '\n' && data[i] != '\r')
                throw new Exception("CSV fields do not match struct fields");

            // Skip over record delimiter(s)
            while (i < data.length && (data[i] == '\n' || data[i] == '\r'))
                i++;
        }

        void parseNextRecord()
        {
            import std.conv : to;
            static if (__VERSION__ >= 2067UL)
                import std.traits : FieldNameTuple;

            assert(i < data.length);
            foreach (field; FieldNameTuple!S)
            {
                alias Value = typeof(__traits(getMember, front, field));

                // Convert value
                const(char)[] strval = parseField();
                static if (is(Value == string))
                {
                    // Optimization for string fields: instead of many small
                    // string allocations, consolidate strings into a string
                    // buffer and take slices of it.
                    if (strval.length + curStringIdx >= stringBuf.length)
                    {
                        // String buffer full; allocate new buffer.
                        stringBuf = new char[stringBufSize];
                        curStringIdx = 0;
                    }
                    stringBuf[curStringIdx .. curStringIdx + strval.length] = 
                        strval[0 .. $];

                    // Since we never take overlapping slices of stringBuf,
                    // it's safe to assume uniqueness here.
                    import std.exception : assumeUnique;
                    __traits(getMember, front, field) = assumeUnique(strval);
                }
                else
                    __traits(getMember, front, field) = strval.to!Value;

                // Skip over field delimiter
                if (i < data.length && data[i] == fieldDelim)
                    i++;
            }

            if (i < data.length && data[i] != '\n' && data[i] != '\r')
                throw new Exception("Record does not match struct");

            // Skip over record delimiter(s)
            while (i < data.length && (data[i] == '\n' || data[i] == '\r'))
                i++;
        }

        void popFront()
        {
            if (i >= data.length)
            {
                empty = true;
                front = front.init;
            }
            else
                parseNextRecord();
        }
    }
    return Result(input);
}

unittest
{
    import std.algorithm.comparison : equal;

    struct S
    {
        string name;
        int year;
        int month;
        int day;
    }
    auto input =
        `name,year,month,day` ~"\n"~
        `John Smith,1995,1,1` ~"\n"~
        `Jane Doe,1996,2,14` ~"\n"~
        `Albert Donahue,1997,3,30`;

    auto r = input.csvByStruct!S;
    assert(r.equal([
        S("John Smith", 1995, 1, 1),
        S("Jane Doe", 1996, 2, 14),
        S("Albert Donahue", 1997, 3, 30)
    ]));

    // Test failure cases
    import std.exception : assertThrown;

    struct T
    {
        string name;
        int age;
        int customerId;
    }
    assertThrown(input.csvByStruct!T.front);

    auto badInput =
        `name,year,month,day` ~"\n"~
        `1995,Jane Doe,2,14`;
    assertThrown(badInput.csvByStruct!S.front);
}

version(none)
unittest
{
    auto data = csvFromUtf8File("ext/cbp13co.txt");
    import std.stdio;
    writefln("%d records", data.length);
}

// vim:set ai sw=4 ts=4 et:
