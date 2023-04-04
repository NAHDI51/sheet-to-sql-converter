#!/bin/bash 

INPUT=$(cat src/vr_information.txt)

while IFS=$'\n' read -r line; do
  echo "Line: $line"
  IFS=$'\t' read -ra words <<< "$line"
  for word in "${words[@]}"; do
    echo "Word: $word"
  done
done <<< "$INPUT"