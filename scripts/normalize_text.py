#!/usr/bin/python3
# -*- coding: utf-8 -*-

import re, sys, os
TEMPORAL_FILE="__tmp"
m_encode="utf-8"

def map_digits(digits):
    m_words=digits.split()
    local_file=TEMPORAL_FILE+m_words[0]+"_"+str(len(m_words))
    os.system("echo \"" + digits + "\"| perl " + "utils/digits2words.perl" + " > "+local_file)
    final_text = str(open(local_file, 'r', encoding=m_encode).read()).replace('\n', '')
    #print(" ---> ", final_text, " in ", local_file, "from ", str(digits))
    os.system("rm "+local_file)
    return final_text

def normalize_word(word, CTMATOR, LEXICONATOR):
    sys.path.insert(1,CTMATOR)
    sys.path.insert(1,LEXICONATOR)
    from word_filter_protocol import v2
    import local.word_clean as wc
    clean = wc.remove_begin_end(wc.normalize_text(wc.clean_word(wc.clean_text(v2(word)))),2)
    aux = ""
    final = ""
    for cc in clean:
        if cc.isdigit():
            aux+=cc
        else:
            if len(aux)>0:
                aux=map_digits(aux)
                final+=aux
                aux=""
            final+=cc
    clean = final+map_digits(aux) if len(aux)>0 else final
    clean_array=clean.split()
    final_clean=""
    for subword in clean_array:
        final_clean+=wc.replace_word(subword)
    return final_clean

def normalize_line(line):
    return re.sub(' +', ' ',line).lower().strip()