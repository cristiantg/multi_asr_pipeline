#!/usr/bin/python3
# -*- coding: utf-8 -*-

# Prepares a ref/hyp file for SCLITE from a folder of single-line txt files
# transcriptions (each transcription in one line).

import sys
if len(sys.argv) != 4:
    print(sys.argv[0] + "Please, specify 3 parameters: INPUT_DIR, OUTPUT_SCLITE_FILE, EXTENSION(S)_INPUT_DIR_FILES_COMMAS")
    # python3 txt2sclite.py input_txt_folder output_sclite_file input_txt_extension (could be a list separated by commas)
    sys.exit(2)
[INPUT_DIR, OUTPUT_SCLITE_FILE, EXTENSION] = sys.argv[1:4]
INPUT_EXTENSION=EXTENSION.split(',')
#print(INPUT_EXTENSION, EXTENSION)

import re, os
from os.path import isfile, join
onlyfiles = [f for f in os.listdir(INPUT_DIR) if isfile(join(INPUT_DIR, f))]
ext_files = 0
with open(OUTPUT_SCLITE_FILE,'w') as sclite_f:
    for file in onlyfiles:
        for ext in INPUT_EXTENSION:
            if file.endswith(ext):
                file_id=file.split('.')[0].replace('-','_')
                #print(file_id)
                ext_files+=1
                with open(join(INPUT_DIR, file), 'r') as f:
                    ##prompt_lower = re.sub('[^a-zA-Z ]+', '',f.read().lower().replace('.',' '))
                    sclite_f.write(re.sub(' +', ' ',f.read().strip())+' ('+file_id.replace('-','_')+'-1)\n')
#print(str(ext_files),'files with the extension(s)',INPUT_EXTENSION)