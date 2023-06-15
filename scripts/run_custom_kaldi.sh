#!/bin/bash

if [ "$#" -ne 7 ]; then
    echo "Usage: $0 kaldi_custom_output_files kaldi_cgn_path am_models input_audio_files input_audio_files_extension kaldi_custom_beam lm_models"
    exit 2
fi
kaldi_custom_output_files="$1"
kaldi_cgn_path="$2"
am_models="$3"
input_audio_files="$4"
input_audio_files_extension="$5"
kaldi_custom_beam="$6"
kaldi_custom_beam="$6"
lm_models="$7"


# 1. DECODE
echo "++ run_custom_kaldi.sh ++"
cd $kaldi_cgn_path
for file in "$input_audio_files"/*$input_audio_files_extension; do
    if [ -e "$file" ]; then
        filename=$(basename "$file")
        filename_without_extension="${filename%.*}"
        $kaldi_cgn_path/uber_single.sh $am_models $input_audio_files $filename $kaldi_custom_output_files $filename_without_extension$decoded_files_extension speaker $kaldi_custom_beam $lm_models > $kaldi_custom_output_files/$filename_without_extension.log 2>&1
    fi
done

# 2. NORMALIZE OUTPUT

# 3. PREPARE HYP FILE

# 4. SCLITE COMMAND