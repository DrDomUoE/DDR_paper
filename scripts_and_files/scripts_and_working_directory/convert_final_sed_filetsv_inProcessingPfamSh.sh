#!/usr/bin/env bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_file> <output_file>"
  exit 1
fi

input_file="$1"
output_file="$2"

awk -F'\t' '
BEGIN {
  OFS = "\t"
}
{
  # For each field in the current line:
  for(i=1; i<=NF; i++) {
    # 1) Remove leading/trailing commas/spaces
    gsub(/^[[:space:],]+|[[:space:],]+$/, "", $i)

    # 2) Collapse multiple commas into a single comma
    gsub(/,+/, ",", $i)

    # 3) Remove spaces around commas
    gsub(/ ,/, ",", $i)
    gsub(/, /, ",", $i)

    # 4) If the field is empty after cleaning, replace with "0"
    if($i == "") {
      $i = "0"
    }
  }

  # Print the modified line with tab separators
  print
}
' "$input_file" > "$output_file"

echo "Cleaned and normalized output written to: $output_file"
