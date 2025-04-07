#!/bin/bash
# Usage: ./transpose_with_order.sh inputfile outputfile
# This script transposes the tab-delimited input file and prepends column 1 from phylogeny_order.txt
# to the first column of each row in the transposed output.
# Then it sorts the result numerically by column 1, transposes it back,
# and finally deletes the first row of the final output.
# Stage 1: Transpose the input file and prepend labels from phylogeny_order.txt
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 inputfile outputfile"
    exit 1
fi

input_file="$1"
output_file="$2"

awk -F'\t' '
{
  for (i = 1; i <= NF; i++) {
    matrix[NR, i] = $i;
  }
  if (NF > max_fields) {
    max_fields = NF;
  }
  rows = NR;
}
END {
  for (i = 1; i <= max_fields; i++) {
    line = "";
    for (j = 1; j <= rows; j++) {
      value = matrix[j, i];
      if (value == "0") {
        value = "NA";
      }
      line = line value "\t";
    }
    sub(/\t$/, "", line);  # Remove trailing tab
    print line;
  }
}' "$input_file" > "$output_file"

# paste phylogeny_order.txt to transposed input


