#!/bin/bash

if [ "$#" -ne 14 ]; then
    echo "Usage: $0 KALDI_LM_PATH KALDI_NL_PATH INPUT_AUDIO_FOLDER OUTPUT_FOLDER REMOVE_IDS UNK_SYMBOL output_path output_extension CTMATOR LEXICONATOR SCLITE sclite_ref_path"
    exit 2
fi
KALDI_LM_PATH=$1
KALDI_NL_PATH=$2
INPUT_AUDIO_FOLDER=$3
INPUT_AUDIO_FILES_EXTENSION=$4
OUTPUT_FOLDER=$5
DECODED_FILES_EXTENSION=$6
REMOVE_IDS=$7
UNK_SYMBOL=$8
OUTPUT_PATH=$9
OUTPUT_EXTENSION=${10}
CTMATOR=${11}
LEXICONATOR=${12}
SCLITE=${13}
SCLITE_REF_PATH=${14}
sclite_hyp_file=$OUTPUT_FOLDER/hyp.txt

# 1. DECODE
echo "++ run_kaldi_nl.sh ++" $(date)
prev_dir=$PWD
export KALDI_ROOT=$KALDI_LM_PATH
cd $KALDI_NL_PATH
$KALDI_NL_PATH/decode_OH.sh $INPUT_AUDIO_FOLDER $OUTPUT_FOLDER

# 2. NORMALIZE OUTPUT
cd $prev_dir
python3 -c "
from normalize_output import process_audio;
process_audio('$INPUT_AUDIO_FOLDER', '$INPUT_AUDIO_FILES_EXTENSION', '$OUTPUT_FOLDER', '$DECODED_FILES_EXTENSION', '$REMOVE_IDS', '$UNK_SYMBOL', '$OUTPUT_PATH', '$OUTPUT_EXTENSION', '$CTMATOR', '$LEXICONATOR')
"

# 3. PREPARE HYP FILE
python3 txt2sclite.py $OUTPUT_PATH $sclite_hyp_file $OUTPUT_EXTENSION

# 4. SCLITE COMMAND
$SCLITE -s -i rm -r $SCLITE_REF_PATH -h $sclite_hyp_file -o all dtl -n "kaldi_nl"

echo "++ run_kaldi_nl.sh finish ++" $(date)