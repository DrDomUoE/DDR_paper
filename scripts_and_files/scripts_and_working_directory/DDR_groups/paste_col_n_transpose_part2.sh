#!/usr/bin/env python3

import sys

def main():
    lines = sys.stdin.read().splitlines()
    if not lines:
        # Empty input, just exit
        return
    
    # Print the first line (header) directly
    print(lines[0])
    
    # The rest of the lines are our data
    data = lines[1:]
    
    def col1_numeric(row):
        # Split on tab
        fields = row.split('\t', 1)
        if not fields:
            return float('inf')
        first_col = fields[0].strip()
        # Try to parse the first column as float
        try:
            return float(first_col)
        except ValueError:
            return float('inf')  # Non-numeric or missing => push to bottom
    
    # Sort in-place by the numeric value of the first column
    data.sort(key=col1_numeric)
    
    # Print the sorted lines
    for line in data:
        print(line)

if __name__ == "__main__":
    main()
