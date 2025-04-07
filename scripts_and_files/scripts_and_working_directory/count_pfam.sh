#!/usr/bin/env bash

# Usage: ./script.sh <input_file> <output_file>
# 1) Remove columns 2 and 3 (tab-delimited).
# 2) Count how many times each line appears.
# 3) Write line + count (tab-delimited) to the output file.

input_file="$1"
output_file="$2"

# Extract the first column, sort, count occurrences, then format the output
cut -f1 "$input_file" \
  | sort \
  | uniq -c \
  | awk '{print "s#>" $2 "#" $1 "#"}' \
  > "$output_file"