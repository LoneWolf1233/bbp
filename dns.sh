#!/usr/bin/env bash
filename="cname_experiment.txt"
outfile="cname_results.txt"

while IFS= read -r line; do
    cname=$(dig "$line" CNAME +short)
    if [ -n "$cname" ]; then
        echo "$line --> $cname"
    else
        echo "$line --> [none]"
    fi
done < "$filename" | tee "$outfile"