#!/usr/bin/python3
# -*- coding: utf-8 -*-

# Prepares a ref/hyp file for SCLITE from a folder of single-line txt files
# transcriptions (each transcription in one line).
#
# If the input folder contains transcriptions from segments from a single file
# you can join them by setting: JOIN_SEGMENTS=1. Otherwise: JOIN_SEGMENTS=0

import sys
ARGS_PLUS_ONE=6
if len(sys.argv) != ARGS_PLUS_ONE:
    print(sys.argv[0] + "Please, specify "+str(ARGS_PLUS_ONE-1)+" parameters: INPUT_DIR, OUTPUT_SCLITE_FILE, JOIN_SEGMENTS[0/1], SEGMENTS_SEP, EXTENSION(S)_INPUT_DIR_FILES_COMMAS")
    # python3 txt2sclite.py input_txt_folder output_sclite_file 0 __ input_txt_extension (could be a list separated by commas)
    sys.exit(2)
[INPUT_DIR, OUTPUT_SCLITE_FILE, JOIN_SEGMENTS, SEGMENTS_SEP, EXTENSION] = sys.argv[1:ARGS_PLUS_ONE]
INPUT_EXTENSION=EXTENSION.split(',')
JOIN_SEGMENTS=int(JOIN_SEGMENTS)==1

import re, os
from os.path import isfile, join
onlyfiles = [f for f in os.listdir(INPUT_DIR) if isfile(join(INPUT_DIR, f))]

final_files = {}
for file in onlyfiles:
    for ext in INPUT_EXTENSION:
        if file.endswith(ext):
            text = ""
            with open(join(INPUT_DIR, file), 'r') as f:
                text=re.sub(' +', ' ',f.read().strip())

            filename=os.path.basename(file).rsplit('.', maxsplit=1)[0]
            single_filename=filename
            aux_num=1
            if JOIN_SEGMENTS:
                fields=filename.split(SEGMENTS_SEP)
                single_filename = fields[0]
                aux_num = int(fields[1])
            file_id=single_filename.replace('-','_') 

            if not JOIN_SEGMENTS:
                final_files[file_id]=text
            else:
                if file_id in final_files:
                    final_files[file_id][aux_num] = text
                else:
                    final_files[file_id]={}
                    final_files[file_id][aux_num] = text

with open(OUTPUT_SCLITE_FILE,'w') as sclite_f:
    if not JOIN_SEGMENTS:
        for file_id in final_files:
            sclite_f.write(final_files[file_id]+' ('+file_id.replace('-','_')+'-1)\n')
    else:
        for file_id in final_files:
            aux_dict=final_files[file_id]
            sclite_f.write(' '.join([aux_dict[key] for key in sorted(aux_dict.keys())])+' ('+file_id.replace('-','_')+'-1)\n')