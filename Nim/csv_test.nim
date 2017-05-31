import os, strutils, streams, tables, parsecsv

const
  Delim = '\t'

proc main() =
  if paramCount() < 3:
    quit("synopsis: " & getAppFilename() & " filename keyfield valuefield")

  let
    filename = paramStr(1)
    keyFieldIndex = parseInt(paramStr(2))
    valueFieldIndex = parseInt(paramStr(3))
    maxFieldIndex = max(keyFieldIndex, valueFieldIndex)

  var
    sumByKey = newCountTable[string]()
    file = newFileStream(filename, fmRead)

  if file == nil:
    quit("cannot open the file " & filename)

  defer: file.close()

  var csv: CsvParser
  open(csv, file, filename, separator=Delim)

  while csv.readRow():
    if len(csv.row) > maxFieldIndex:
      sumByKey.inc(csv.row[keyFieldIndex], parseInt(csv.row[valueFieldIndex]))

  if sumByKey.len() == 0:
    echo "No entries"
  else:
    let largest = sumByKey.largest()
    echo "max_key: ", largest[0], " sum: ", largest[1]

main()
