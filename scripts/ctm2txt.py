#!/usr/bin/python3
# -*- coding: utf-8 -*-
# Transforms a multi-line CTM file into a single TXT file


import sys
TOTAL_ARGS_PLUS_ONE=5+1
if len(sys.argv) != TOTAL_ARGS_PLUS_ONE:
    print(sys.argv[0] + "Please, specify "+str(TOTAL_ARGS_PLUS_ONE-1)+" parameters: INPUT_FILE, OUTPUT_DIR, OUTPUT_FILE_EXTENSION, CTMATOR, LEXICONATOR")
    # python3 ctm2txt.py INPUT_FILE OUTPUT_DIR .txt CTMATOR_PATH LEXICONATOR_PATH
    sys.exit(2)
[INPUT_FILE, OUTPUT_DIR, OUTPUT_FILE_EXTENSION,CTMATOR, LEXICONATOR] = sys.argv[1:TOTAL_ARGS_PLUS_ONE]
#sys.path.insert(1, CTMATOR)
#sys.path.insert(1,LEXICONATOR)
word_field_index=4

import os
from normalize_text import normalize_word as nw
from normalize_text import normalize_line as nl

def extract_text_from_ctm(line):
    fields = line.split(' ')
    if len(fields) == 1:
        fields = line.split('\t')
    if len(fields) >= 5:
        return nw(fields[word_field_index],CTMATOR,LEXICONATOR)
    else:
        return None

base_filename = os.path.basename(INPUT_FILE).rsplit('.', maxsplit=1)[0]
output_file = os.path.join(OUTPUT_DIR, base_filename + OUTPUT_FILE_EXTENSION)
with open(output_file, 'w') as file_out:
    with open(INPUT_FILE, 'r') as file_in:
        words = []
        for line in file_in:
            text = extract_text_from_ctm(line.strip())
            if text is not None:
                words.append(text)
    file_out.write(nl(" ".join(words)) + '\n')