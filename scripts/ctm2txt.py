# TODO: parameters + words in one line

#!/usr/bin/python3
# -*- coding: utf-8 -*-

import glob
import os

def extract_text_from_ctm(line):
    fields = line.split('\t')
    if len(fields) >= 5:
        return fields[4]
    else:
        return None

# Folder path containing JSON files
folder_path = "path/to/folder"

# Get a list of JSON files in the folder
json_files = glob.glob(os.path.join(folder_path, "*.json"))

# Process each JSON file
for json_file in json_files:
    # Get the base filename without extension
    base_filename = os.path.splitext(os.path.basename(json_file))[0]
    # Output file name with .txt extension
    output_file = os.path.join(folder_path, base_filename + ".txt")

    # Open output file in write mode
    with open(output_file, 'w') as file_out:
        # Open the JSON file
        with open(json_file, 'r') as file_in:
            # Iterate over each line in the JSON file
            for line in file_in:
                text = extract_text_from_ctm(line.strip())
                if text is not None:
                    file_out.write(text + '\n')

