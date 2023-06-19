#!/bin/bash

if [ "$#" -ne 17 ]; then
    echo "Usage: $0 WHISPER_T_PATH, INPUT_AUDIO_FOLDER, INPUT_AUDIO_FILES_EXTENSION, OUTPUT_FOLDER, DECODED_FILES_EXTENSION, WHISPER_T_MODEL, WHISPER_T_MODELS, WHISPER_T_LANG, WHISPER_T_PROMPTS_PATH, REMOVE_IDS, UNK_SYMBOL, OUTPUT_PATH, OUTPUT_EXTENSION, CTMATOR, LEXICONATOR, SCLITE, SCLITE_REF_PATH."
    exit 2
fi
WHISPER_T_PATH="$1"
INPUT_AUDIO_FOLDER="$2"
INPUT_AUDIO_FILES_EXTENSION="$3"
OUTPUT_FOLDER="$4"
DECODED_FILES_EXTENSION="$5"
WHISPER_T_MODEL="$6"
WHISPER_T_MODELS="$7"
WHISPER_T_LANG="$8"
WHISPER_T_PROMPTS_PATH="$9"
REMOVE_IDS="${10}"
UNK_SYMBOL="${11}"
OUTPUT_PATH="${12}"
OUTPUT_EXTENSION="${13}"
CTMATOR="${14}"
LEXICONATOR="${15}"
SCLITE="${16}"
SCLITE_REF_PATH="${17}"
sclite_hyp_file=$OUTPUT_FOLDER/hyp.txt

# 1. DECODE
echo "++ run_whisper_t.sh ++" $(date)
prev_dir=$PWD
cd $WHISPER_T_PATH && source venv/bin/activate
python3 decode_whispertimestamped_folder.py $INPUT_AUDIO_FOLDER $WHISPER_T_MODEL $WHISPER_T_LANG $OUTPUT_FOLDER $WHISPER_T_MODELS $WHISPER_T_PROMPTS_PATH


# 2. NORMALIZE OUTPUT
cd $prev_dir
python3 -c "
from normalize_output import process_audio;
process_audio('$INPUT_AUDIO_FOLDER', '$INPUT_AUDIO_FILES_EXTENSION', '$OUTPUT_FOLDER', '$DECODED_FILES_EXTENSION', '$REMOVE_IDS', '$UNK_SYMBOL', '$OUTPUT_PATH', '$OUTPUT_EXTENSION', '$CTMATOR', '$LEXICONATOR')
"

# 3. PREPARE HYP FILE
python3 txt2sclite.py $OUTPUT_PATH $sclite_hyp_file $OUTPUT_EXTENSION

# 4. SCLITE COMMAND
$SCLITE -s -i rm -r $SCLITE_REF_PATH -h $sclite_hyp_file -o all dtl -n "whisper_t"

echo "++ run_whisper_t.sh finish ++" $(date)