#!/bin/bash

# Usage: ./split_by_columns.sh input_file
# Splits 'input_file' by columns, naming each output file after
# the header in that column and prepending the "Homo" column entry
# on each line.

INPUT_FILE="$1"
if [[ -z "$INPUT_FILE" ]]; then
  echo "Usage: $0 input_file"
  exit 1
fi

# Read the header line into an array of column names.
read -r HEADER_LINE < "$INPUT_FILE"
# Convert header into a Bash array by splitting on whitespace (tabs/spaces).
IFS=$'\t' read -r -a COL_NAMES <<< "$HEADER_LINE"

# Identify the index of the "Homo" column by searching the array.
# Bash arrays are zero-based; fields in AWK are 1-based.
HOMO_COL_INDEX=-1
for i in "${!COL_NAMES[@]}"; do
  if [[ "${COL_NAMES[$i]}" == "Homo" ]]; then
    HOMO_COL_INDEX="$((i+1))"
    break
  fi
done

# If we didn't find a "Homo" column, exit with an error.
if [[ "$HOMO_COL_INDEX" -lt 1 ]]; then
  echo "Error: Could not find a 'Homo' column in the header."
  exit 1
fi

# Count total number of columns (fields).
NUM_COLS="${#COL_NAMES[@]}"

# For each column, we produce a .out.txt file named after the header.
for (( col_idx=1; col_idx<="$NUM_COLS"; col_idx++ )); do
  col_name="${COL_NAMES[$((col_idx-1))]}"
  out_file="${col_name}.out.txt"

  # Use AWK to:
  # - skip the first line (NR==1) because it's the header
  # - print the "Homo" column, then a tab, then the current column
  awk -v homo="$HOMO_COL_INDEX" -v c="$col_idx" '
    BEGIN { FS="\t" }
    NR == 1 { next }  # Skip header
    {
      print $homo "\t" $c
    }
  ' "$INPUT_FILE" > "$out_file"

  echo "Wrote column '$col_name' to $out_file"
done
rm Homo.out.txt
