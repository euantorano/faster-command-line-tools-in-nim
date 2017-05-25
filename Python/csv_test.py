#!/usr/bin/env python

import argparse
import fileinput
import collections

def main():
    parser = argparse.ArgumentParser(description='Sum a column.')
    parser.add_argument('file', type=open)
    parser.add_argument('key_field_index', type=int)
    parser.add_argument('value_field_index', type=int)

    args = parser.parse_args()
    delim = '\t'

    max_field_index = max(args.key_field_index, args.value_field_index)
    sum_by_key = collections.Counter()

    for line in args.file:
        fields = line.rstrip('\n').split(delim)
        if max_field_index < len(fields):
            sum_by_key[fields[args.key_field_index]] += int(fields[args.value_field_index])

    max_entry = sum_by_key.most_common(1);
    if len(max_entry) == 0:
        print 'No entries'
    else:
        print 'max_key:', max_entry[0][0], 'sum:', max_entry[0][1]

if __name__ == '__main__':
    main()