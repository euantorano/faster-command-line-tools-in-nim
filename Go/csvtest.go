package main

import (
	"bufio"
	"fmt"
	"io"
	"math"
	"os"
	"strconv"
	"strings"
)

func maxEntry(dict map[int]int) (key, value int) {
	mk := 0
	mv := 0

	for k, v := range dict {
		if mv < v {
			mv = v
			mk = k
		}
	}
	return mk, mv
}

func main() {
	sumByKey := make(map[int]int)
	delim := "\t"

	if len(os.Args) < 3 {
		fmt.Println("synopsis: csvtest filename keyfield valuefield")
		os.Exit(1)
	}

	filename := os.Args[1]
	keyFieldIndex, _ := strconv.Atoi(os.Args[2])
	valueFieldIndex, _ := strconv.Atoi(os.Args[3])
	maxFieldIndex := int(math.Max(float64(keyFieldIndex),
		float64(valueFieldIndex)))
	file, err := os.Open(filename)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	reader := bufio.NewReader(file)

	for {
		line, err := reader.ReadString('\n')
		if err == io.EOF {
			break
		}
		record := strings.Split(line, delim)
		if maxFieldIndex < len(record) {
			value, _ := strconv.Atoi(record[valueFieldIndex])
			key, _ := strconv.Atoi(record[keyFieldIndex])
			sumByKey[key] += value
		}
	}

	if len(sumByKey) == 0 {
		fmt.Println("No entries")
	} else {
		maxKey, maxValue := maxEntry(sumByKey)
		fmt.Println("max_key:", maxKey, "sum:", maxValue)
	}
}
