#!/usr/bin/python3
# -*- coding: utf-8 -*-

import re, sys

def normalize_word(word, CTMATOR, LEXICONATOR):
    sys.path.insert(1,CTMATOR)
    sys.path.insert(1,LEXICONATOR)
    from word_filter_protocol import v2
    import local.word_clean as wc
    return wc.remove_begin_end(wc.normalize_text(wc.clean_word(wc.clean_text(v2(word)))),2)

def normalize_line(line):
    return re.sub(' +', ' ',line).lower().strip()