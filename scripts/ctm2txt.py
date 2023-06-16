# TODO: words with text normalized




#!/usr/bin/python3
# -*- coding: utf-8 -*-
# Transforms a multi-line CTM file into a single TXT file


import sys
TOTAL_ARGS_PLUS_ONE=3+1
if len(sys.argv) != TOTAL_ARGS_PLUS_ONE:
    print(sys.argv[0] + "Please, specify "+str(TOTAL_ARGS_PLUS_ONE-1)+" parameters: INPUT_FILE, OUTPUT_DIR, OUTPUT_FILE_EXTENSION")
    # python3 ctm2txt.py INPUT_FILE OUTPUT_DIR .txt
    sys.exit(2)
[INPUT_FILE, OUTPUT_DIR, OUTPUT_FILE_EXTENSION] = sys.argv[1:TOTAL_ARGS_PLUS_ONE]

import os
word_field_index=4

def extract_text_from_ctm(line):
    fields = line.split(' ')
    if len(fields) == 1:
        fields = line.split('\t')
    if len(fields) >= 5:
        return fields[word_field_index]
    else:
        return None


base_filename = os.path.splitext(os.path.basename(INPUT_FILE))[0]
output_file = os.path.join(OUTPUT_DIR, base_filename + OUTPUT_FILE_EXTENSION)
with open(output_file, 'w') as file_out:
    with open(INPUT_FILE, 'r') as file_in:
        words = []
        for line in file_in:
            text = extract_text_from_ctm(line.strip())
            if text is not None:
                words.append(text)
    file_out.write(" ".join(words) + '\n')