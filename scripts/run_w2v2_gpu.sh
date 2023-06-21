#!/bin/bash

if [ $# -ne 15 ]; then
    echo "Error: Invalid number of parameters!"
    echo "Usage: $0 INPUT_AUDIO_FOLDER INPUT_AUDIO_FILES_EXTENSION OUTPUT_FOLDER DECODED_FILES_EXTENSION W2V2_GPU_REPO W2V2_GPU_SOURCE W2V2_GPU_KEEP_ALIVE REMOVE_IDS UNK_SYMBOL OUTPUT_PATH OUTPUT_EXTENSION CTMATOR LEXICONATOR SCLITE SCLITE_REF_PATH"
    exit 2
fi
INPUT_AUDIO_FOLDER="$1"
INPUT_AUDIO_FILES_EXTENSION="$2"
OUTPUT_FOLDER="$3"
DECODED_FILES_EXTENSION="$4"
W2V2_GPU_REPO="$5"
W2V2_GPU_SOURCE="$6"
W2V2_GPU_KEEP_ALIVE="$7"
REMOVE_IDS="$8"
UNK_SYMBOL="$9"
OUTPUT_PATH="${10}"
OUTPUT_EXTENSION="${11}"
CTMATOR="${12}"
LEXICONATOR="${13}"
SCLITE="${14}"
SCLITE_REF_PATH="${15}"
sclite_hyp_file=$OUTPUT_FOLDER/hyp.txt

# 1. DECODE
# Pony without GPU:
echo "++ run_w2v2_gpu.sh ++" $(date)
ssh pipsqueak "source $W2V2_GPU_SOURCE;python $W2V2_GPU_REPO/repo/controller.py -input_dir $INPUT_AUDIO_FOLDER -keep_alive_minutes $W2V2_GPU_KEEP_ALIVE -prepare -output_dir $OUTPUT_FOLDER "

# 2. NORMALIZE OUTPUT
echo "SCLITE - w2v2_gpu " $(date)
python3 -c "
from normalize_output import process_audio;
process_audio('$INPUT_AUDIO_FOLDER', '$INPUT_AUDIO_FILES_EXTENSION', '$OUTPUT_FOLDER', '$DECODED_FILES_EXTENSION', '$REMOVE_IDS', '$UNK_SYMBOL', '$OUTPUT_PATH', '$OUTPUT_EXTENSION', '$CTMATOR', '$LEXICONATOR')
"

# 3. PREPARE HYP FILE
python3 txt2sclite.py $OUTPUT_PATH $sclite_hyp_file $OUTPUT_EXTENSION

if [ -e "$SCLITE_REF_PATH" ]; then
    # 4. SCLITE COMMAND
    $SCLITE -s -i rm -r $SCLITE_REF_PATH -h $sclite_hyp_file -o all dtl -n "w2v2_gpu"
else
    echo "Skipped SCLITE - w2v2_gpu"
fi

echo "++ run_w2v2_gpu.sh finish ++" $(date)