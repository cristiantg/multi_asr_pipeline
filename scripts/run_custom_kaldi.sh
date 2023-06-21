#!/bin/bash

if [ "$#" -ne 15 ]; then
    echo "Usage: $0 kaldi_custom_output_files kaldi_cgn_path am_models input_audio_files input_audio_files_extension kaldi_custom_beam lm_models REMOVE_IDS UNK_SYMBOL output_path output_extension CTMATOR LEXICONATOR SCLITE SCLITE_REF_PATH "
    exit 2
fi
kaldi_custom_output_files="$1"
kaldi_cgn_path="$2"
am_models="$3"
input_audio_files="$4"
input_audio_files_extension="$5"
kaldi_custom_beam="$6"
lm_models="$7"
REMOVE_IDS="$8"
UNK_SYMBOL="$9"
output_path="${10}"
output_extension="${11}"
CTMATOR="${12}"
LEXICONATOR="${13}"
SCLITE="${14}"
SCLITE_REF_PATH="${15}"
decoded_files_extension=.ctm
sclite_hyp_file=$kaldi_custom_output_files/../hyp.txt


# 1. DECODE
echo "++ run_custom_kaldi.sh ++" $(date)
prev_dir=$PWD
cd $kaldi_cgn_path
for file in "$input_audio_files"/*$input_audio_files_extension; do
    if [ -e "$file" ]; then
        filename=$(basename "$file")
        filename_without_extension="${filename%.*}"
        $kaldi_cgn_path/uber_single.sh $am_models $input_audio_files $filename $kaldi_custom_output_files $filename_without_extension$decoded_files_extension speaker $kaldi_custom_beam $lm_models > $kaldi_custom_output_files/$filename_without_extension.log 2>&1
    fi
done

# 2. NORMALIZE OUTPUT
cd $prev_dir
python3 -c "
from normalize_output import process_audio;
process_audio('$input_audio_files', '$input_audio_files_extension', '$kaldi_custom_output_files', '$decoded_files_extension', '$REMOVE_IDS', '$UNK_SYMBOL', '$output_path', '$output_extension', '$CTMATOR', '$LEXICONATOR')
"

# 3. PREPARE HYP FILE
python3 txt2sclite.py $output_path $sclite_hyp_file $output_extension

m_preffix=$(basename "$lm_models")
if [ -e "$SCLITE_REF_PATH" ]; then
    # 4. SCLITE COMMAND
    $SCLITE -s -i rm -r $SCLITE_REF_PATH -h $sclite_hyp_file -o all dtl -n "kaldi_$m_preffix"
else
    echo "Skipped SCLITE - kaldi_$m_preffix"
fi

echo "++ run_custom_kaldi.sh finish ++" $(date)