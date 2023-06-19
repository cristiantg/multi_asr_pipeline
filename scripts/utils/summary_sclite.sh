#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <root_folder> <output_file>"
  exit 1
fi

# Root folder path
root_folder="$1"

# Output file path
output_file="$2"
echo "| ASR system               | # Fil  # Wrd  | Corr    Sub     Del     Ins    Err    S.Err |" > $output_file

# Find all subfolders (level 1) within the root folder
subfolders=("$root_folder"/*)

# Iterate over the subfolders
for folder in "${subfolders[@]}"; do
  # Find .sys files within the current subfolder and extract lines starting with "| Sum/Avg"
  
  find "$folder" -maxdepth 1 -type f -name "*.sys" | while read -r file; do
    # Extract lines starting with "| Sum/Avg" from the file
    grep "Sum/Avg" "$file" | sed "s/^/$(basename "$file")\n/" >> "$output_file"
  done
done

