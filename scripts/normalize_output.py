#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os, json
from normalize_text import normalize_word as nw
from normalize_text import normalize_line as nl

def __list_files_with_extension(input_folder, extension):
    file_list = []
    for root, dirs, files in os.walk(input_folder):
        for file in files:
            if file.endswith(extension):
                file_list.append(os.path.join(root, file))
    return file_list

def __normalize_content(line,CTMATOR,LEXICONATOR):
    words=[]
    for word in line.strip().split():
        words.append(nw(word,CTMATOR,LEXICONATOR))
    return nl(" ".join(words))

# REMOVE_IDS=0 (No), REMOVE_IDS=1 (Yes), REMOVE_IDS=2 (Extract "text" from json), REMOVE_IDS=3 (ctm to txt)
def __read_files_write_content(file_list, extension, decoded_folder, output_path, output_extension, CTMATOR, LEXICONATOR, REMOVE_IDS=0, UNK_SYMBOL="<unk>"):
    REMOVE_IDS=int(REMOVE_IDS)
    for file_path in file_list:
        filename = os.path.basename(file_path).rsplit('.', maxsplit=1)[0]
        read_file_path = os.path.join(decoded_folder, filename + extension)
        try:
            with open(read_file_path, 'r') as read_file:
                hyp = ""             
                if REMOVE_IDS==3:                
                    os.system("python3 ctm2txt.py "+read_file_path+ " "+output_path+" "+ output_extension+" "+ CTMATOR+" "+ LEXICONATOR)
                elif REMOVE_IDS==2:
                    with open(os.path.join(output_path,filename+output_extension), 'w') as file_out:
                        file_out.write(__normalize_content(json.loads(read_file.read())["text"],CTMATOR,LEXICONATOR) + '\n')
                else:
                    with open(os.path.join(output_path,filename+output_extension), 'w') as file_out:
                        lines=[]
                        for line in read_file:
                            if REMOVE_IDS==1:
                                line = line[:line.rfind("(")]
                            lines.append(__normalize_content(line,CTMATOR,LEXICONATOR))
                        file_out.write(" ".join(lines) + '\n')
        except FileNotFoundError:
            print(f"File {read_file_path} not found.")
        except Exception as e:
            print(f"An error occurred while reading {read_file_path}: {str(e)}")


def process_audio(audio_path, audio_extension, transcripts_folder_path, transcripts_extension, REMOVE_IDS, UNK_SYMBOL, output_path, output_extension, CTMATOR, LEXICONATOR):
    __read_files_write_content(__list_files_with_extension(audio_path, audio_extension), transcripts_extension, transcripts_folder_path, output_path, output_extension, CTMATOR, LEXICONATOR, REMOVE_IDS, UNK_SYMBOL)