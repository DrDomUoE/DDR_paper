#!/bin/bash
# Usage: ./transpose.sh inputfile outputfile

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 inputfile outputfile"
    exit 1
fi

input_file="$1"
output_file="$2"

# First AWK: Transpose input and convert "0" cells to "NA"
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
}' "$input_file" |

# Sort the transposed lines alphabetically by the first field
sort -t $'\t' -k1,1 |

# Second AWK: Transpose again to restore original orientation
awk -F'\t' '
{
  for (i = 1; i <= NF; i++) {
    arr[NR, i] = $i;
  }
  if (NF > max) {
    max = NF;
  }
  rows = NR;
}
END {
  for (i = 1; i <= max; i++) {
    line = "";
    for (j = 1; j <= rows; j++) {
      line = line arr[j, i] "\t";
    }
    sub(/\t$/, "", line);
    print line;
  }
}' > "$output_file"
