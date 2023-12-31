#!/bin/sh

# ******************* Mega-pipeline *********************
# This script decodes a bunch of audio files in a folder 
# and optionally uses SCLITE to calculate the WER.
#
# INPUT: 
#   1. One folder with audio files
#   2. (Optional) One folder with UTF-8 single-line txt files (transcriptions)
#   Note: It is possible to automatically obtain the standard transcriptions of the files from
#   (1) multi-line txt files, (2) CTM files and (3) Whisper-t-based JSON ("txt" field) files
#
# OUTPUT:
#   1. Subfolders with each ASR system output
#   2. (Optional) ref.txt file used for scoring with SCLITE
# ******************* Mega-pipeline *********************

# ssh thunderlane
# nvidia-smi # Check whteher a GPU is free. Otherwise, change to other Pony
# project=/vol/tensusers/ctejedor/multi_asr_pipeline/scripts && cd $project && clear && pwd
# vim uber.sh #change the paths of the ## CONSTANTS ##  accordingly
#       (Optional) chmod 700 ./*
#       (Optional) rm -r nohup.out ../input ../output
# nohup time ./uber.sh >> nohup-raw_MJ_full.out &
#
#
# When all processes are done:
# utils/summary_sclite.sh ../output ../output/summary.txt
# mv nohup.out ../output/

# Requires
# 1. A pony with a GPU on Ponyland and:
# KALDI_NL: /vol/customopt/lamachine.stable
# SCLITE: $KALDI_NL/opt/kaldi/tools/sctk/bin/sclite
# 2. Github repositories:
# CTMATOR: https://github.com/cristiantg/ctmator/
# LEXICONATOR: https://github.com/cristiantg/lexiconator
# KALDI_CGN: https://github.com/cristiantg/kaldi_egs_CGN/tree/onPonyLand


############################### CONSTANTS ###############################
# Steps mega pipeline, change binary values accordingly: [0-1] -> 0=>Skip, 1=>Run.
prepare_ref=1; normalize_sox=1; split_segments=0
kaldi_nl=1; whisper_t=1; w2v2_gpu=1; kaldi_custom_v2_2022=1; kaldi_custom_v1_2023=1; kaldi_custom_v2_2023=1

# I. Please change the following values whenever you run this script:
PROJECT=/vol/tensusers/ctejedor/multi_asr_pipeline # PATH TO THIS GITHUB REPO IN YOUR PC
PROJECT_SUFFIX="-raw_MJ_full"
PROJECT_OUTPUT=$PROJECT/output$PROJECT_SUFFIX
### INPUT - AUDIO FILES:
raw_input_audio_files=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/homed_wav
raw_input_audio_files_extension=.wav
### INPUT - TRANSCRIPTION FILES (optional)
### SET: input_transcriptions_ground_truth=- for not using SCLITE (only ASR decoding)
input_transcriptions_ground_truth=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/ctmator/ref_original
# The following variables will not make effect if input_transcriptions_ground_truth=-
input_transcriptions_ground_truth_extension=.txt #.ctm, .txt, .prompt, etc.
input_transcriptions_ground_truth_remove_ids="0" # 0=no modif, 1=remove sclite ids at the end of the lines, 2="text" from json, 3=CTM
input_transcriptions_ground_truth_unk_symbol="<unk>"
# Optional: A Kaldi-standard segments file is required for splitting audio files (you might obtain it first from kaldi_nl)
# It only works if "split_segments=1"
input_split_audio_files_segments_file=$PROJECT_OUTPUT/kaldi_nl/intermediate/data/ALL/segments
# Optional: Folder with .prompt files, otherwise: WHISPER_T_PROMPTS_PATH=0
WHISPER_T_PROMPTS_PATH=0


## CHANGE JUST ONCE, WHEN YOU SET-UP THIS PROJECT FOR THE FIRST TIME:
KALDI_NL_PATH=/vol/customopt/lamachine.stable/opt/kaldi_nl
KALDI_LM_PATH=/vol/customopt/lamachine.stable/opt/kaldi
SCLITE=$KALDI_LM_PATH/tools/sctk/bin/sclite
CTMATOR=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/ctmator
LEXICONATOR=/home/ctejedor/python-scripts/lexiconator
KALDI_CGN=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi/egs/kaldi_egs_CGN/s5
kaldi_nl_remove_ids="1" # remove ids at the end of the sentence
kaldi_nl_unk_symbol="<unk>"
WHISPER_T_PATH=/vol/tensusers5/ctejedor/whisper
WHISPER_T_MODEL="large"
WHISPER_T_MODELS=$WHISPER_T_PATH/models
WHISPER_T_LANG=nl
whisper_t_remove_ids="2" # extract "text" from json
whisper_t_unk_symbol="<unk>"
W2V2_GPU_REPO=/vol/tensusers/mbentum/AUDIOSERVER/
W2V2_GPU_SOURCE=$W2V2_GPU_REPO/audioserver_env/bin/activate
W2V2_GPU_KEEP_ALIVE=0
w2v2_gpu_remove_ids="0" # extract without modification
w2v2_gpu_unk_symbol="<unk>"
kaldi_custom_am_models_v2_2022=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/models/NL/UTwente/HMI/AM/CGN_all/nnet3_online/tdnn/v1.0
kaldi_custom_lm_models_v2_2022=/vol/tensusers3/ctejedor/lrec_homed/homed_90_run6/out_cgn
kaldi_custom_v2_2022_remove_ids="3" #ctm
kaldi_custom_v2_2022_unk_symbol="<unk>"
kaldi_custom_am_models_v1_2023=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/AM/tdnn1a_sp_bi_online
kaldi_custom_lm_models_v1_2023=$kaldi_custom_am_models_v1_2023/graph_s_02
kaldi_custom_v1_2023_remove_ids="3" #ctm
kaldi_custom_v1_2023_unk_symbol="<unk>"
kaldi_custom_am_models_v2_2023=$kaldi_custom_am_models_v1_2023
kaldi_custom_lm_models_v2_2023=$kaldi_custom_am_models_v2_2023/graph_s_09
kaldi_custom_v2_2023_remove_ids="3" #ctm
kaldi_custom_v2_2023_unk_symbol="<unk>"


# II. Generated (no need to change)
## In case you already have this file, you might set manually its value to skip the REF file preparation process
OUTPUT_REF_FILE=$PROJECT_OUTPUT/ref.txt
OUTPUT_STANDARD_TXT=output_std
OUTPUT_STANDARD_TXT_EXTENSION=.txt
input_audio_files=$PROJECT_OUTPUT/_input$PROJECT_SUFFIX # FINAL-1: Here the audio files will be decoded
input_audio_files_extension=.wav # Extension of the audio files to be decoded
input_transcriptions_ground_truth_std=$PROJECT_OUTPUT/_transcriptions$PROJECT_SUFFIX # FINAL-2: These are the single-line txt files
input_transcriptions_ground_truth_std_extension=.txt # Extension of the single-line txt files
input_split_audio_files_condition_true="1"
input_split_audio_files_condition_false="0"
input_split_audio_files_extension=$input_audio_files_extension
input_split_audio_files_symbol="__"
input_split_audio_files="$input_audio_files"
input_split_audio_files_condition="$input_split_audio_files_condition_false"
if [ $split_segments -eq 1 ]; then
    input_split_audio_files="$input_audio_files-split"
    input_split_audio_files_condition="$input_split_audio_files_condition_true"
fi
kaldi_nl_output=$PROJECT_OUTPUT/kaldi_nl
kaldi_nl_output_std=$kaldi_nl_output/$OUTPUT_STANDARD_TXT
kaldi_nl_decoded_extension=.txt
kaldi_nl_nohup=$kaldi_nl_output/_kaldi_nl_nohup.out
whisper_t_output=$PROJECT_OUTPUT/whisper_t
whisper_t_output_std=$whisper_t_output/$OUTPUT_STANDARD_TXT
whisper_t_decoded_extension=.json
whisper_t_nohup=$whisper_t_output/_whisper_t_nohup.out
w2v2_gpu_output=$PROJECT_OUTPUT/w2v2_gpu
w2v2_gpu_output_std=$w2v2_gpu_output/$OUTPUT_STANDARD_TXT
w2v2_gpu_decoded_extension=.txt
w2v2_gpu_nohup=$w2v2_gpu_output/_w2v2_gpu_nohup.out
kaldi_custom_v2_2022_output=$PROJECT_OUTPUT/kaldi_custom_v2_2022
kaldi_custom_v2_2022_nohup=$kaldi_custom_v2_2022_output/_kaldi_custom_v2_2022_nohup.out
kaldi_custom_v2_2022_output_files=$kaldi_custom_v2_2022_output/decoded
kaldi_custom_v2_2022_beam=20
kaldi_custom_v2_2022_output_std=$kaldi_custom_v2_2022_output/$OUTPUT_STANDARD_TXT
kaldi_custom_v1_2023_output=$PROJECT_OUTPUT/kaldi_custom_v1_2023
kaldi_custom_v1_2023_nohup=$kaldi_custom_v1_2023_output/_kaldi_custom_v1_2023_nohup.out
kaldi_custom_v1_2023_output_files=$kaldi_custom_v1_2023_output/decoded
kaldi_custom_v1_2023_beam=20
kaldi_custom_v1_2023_output_std=$kaldi_custom_v1_2023_output/$OUTPUT_STANDARD_TXT
kaldi_custom_v2_2023_output=$PROJECT_OUTPUT/kaldi_custom_v2_2023
kaldi_custom_v2_2023_nohup=$kaldi_custom_v2_2023_output/_kaldi_custom_v2_2023_nohup.out
kaldi_custom_v2_2023_output_files=$kaldi_custom_v2_2023_output/decoded
kaldi_custom_v2_2023_beam=20
kaldi_custom_v2_2023_output_std=$kaldi_custom_v2_2023_output/$OUTPUT_STANDARD_TXT
############################### CONSTANTS ###############################

echo
echo $(date)
echo "++ uber.sh script ++"
directories="$KALDI_NL_PATH $KALDI_LM_PATH $CTMATOR $LEXICONATOR $KALDI_CGN 
  $WHISPER_T_PATH $WHISPER_T_MODELS $W2V2_GPU_REPO $kaldi_custom_am_models_v2_2022 
  $kaldi_custom_lm_models_v2_2022 $kaldi_custom_am_models_v1_2023 
  $kaldi_custom_lm_models_v1_2023 $kaldi_custom_am_models_v2_2023 
  $kaldi_custom_lm_models_v2_2023"

for directory in $directories; do
  if [ ! -d "$directory" ]; then
    echo "Directory '$directory' does not exist"
    echo "Aborted execution of uber.sh script."
    echo
    exit 2
  fi
done

# Check file
if [ ! -f "$SCLITE" ]; then
  echo "File '$SCLITE' does not exist"
  echo "Aborted execution of uber.sh script."
  echo
  exit 2
fi



echo " --> input_audio_files: $input_audio_files"
if [ $split_segments -eq 1 ]; then
    echo " --> input_split_audio_files: $input_split_audio_files"
    if [ ! -f $input_split_audio_files_segments_file ]; then
        echo "An existing Kaldi-based segments file is needed to split the audio files"
        echo $(date)
        echo "Aborted execution of uber.sh script."
        echo
        exit 2
    fi

    if [ $normalize_sox -eq 1 ]; then   
        echo " ----> Cleaning the previous content..."
        rm -rf $input_split_audio_files
    fi
fi
echo " --> input_transcriptions_ground_truth_std: $input_transcriptions_ground_truth_std"
echo

if [ $normalize_sox -eq 1 ]
then
    echo "+-+ 0.1.1 Preparing audio files with sox:"
    echo " INPUT (raw audio): $raw_input_audio_files"
    echo " OUTPUT (normalized audio files with sox): $input_audio_files"
    echo $(date)
    rm -rf $PROJECT/scripts/__pycache__ && mkdir -p $input_audio_files
    $PROJECT/scripts/utils/normalize_audio.sh "$raw_input_audio_files" "$input_audio_files" "$raw_input_audio_files_extension" "$input_audio_files_extension"
    echo "--> Note: Audio files will be split in segments later only if you selected custom Kaldi ASR decoding"
    echo "--> Done " $(date)
    echo

    if [ $split_segments -eq 1 ]; then
        echo "+-+ 0.1.2 Split audio files with sox:"
        echo $(date)
        python3 utils/split_segments.py "$input_audio_files" "$input_split_audio_files" "$input_split_audio_files_segments_file" "$input_audio_files_extension" "$input_split_audio_files_symbol"
        echo "--> Done " $(date)
    else
        echo "0.1.2 --> Skipped"
    fi

else
    echo "0.1.1 and 0.1.2 --> Skipped"
fi


if [ $prepare_ref -eq 1 ] &&  [ "$input_transcriptions_ground_truth" != "-" ];
then
    echo
    echo "+-+ 0.2 SCLITE ref file preparation" $(date)
    echo "-> This step is not recommended to be executed more than one time at the same time"
    echo "-> A temporal file is created for mapping digits (and will be automatically deleted)"
    ## rm -rf $PROJECT_OUTPUT ## Very dangerous --> Do it manually
    mkdir -p $PROJECT_OUTPUT $input_transcriptions_ground_truth_std
    # Takes the "raw transcription files" and prepares a single ref.file with all txt files in "transcriptions" folder
    echo "-> Normalizing transcriptions (step 1/2) output2txt ..."
    python3 -c "from normalize_output import process_audio; process_audio('$input_audio_files', '$input_audio_files_extension','$input_transcriptions_ground_truth', '$input_transcriptions_ground_truth_extension','$input_transcriptions_ground_truth_remove_ids', '$input_transcriptions_ground_truth_unk_symbol','$input_transcriptions_ground_truth_std', '$input_transcriptions_ground_truth_std_extension', '$CTMATOR', '$LEXICONATOR')"
    echo "-> Normalizing transcriptions (step 2/2) txt2sclite ..."
    python3 $PROJECT/scripts/txt2sclite.py $input_transcriptions_ground_truth_std $OUTPUT_REF_FILE $input_split_audio_files_condition_false $input_split_audio_files_symbol $input_transcriptions_ground_truth_std_extension
    echo "--> Done " $(date)
else
    echo "0.2 --> Skipped"
fi

echo

if [ $kaldi_nl -eq 1 ]
then
    echo "+-+ 1. KALDI_NL" $(date)
    mkdir -p $kaldi_nl_output $kaldi_nl_output_std
    nohup time $PROJECT/scripts/run_kaldi_nl.sh $KALDI_LM_PATH $KALDI_NL_PATH $input_audio_files $input_audio_files_extension $kaldi_nl_output $kaldi_nl_decoded_extension $kaldi_nl_remove_ids $kaldi_nl_unk_symbol $kaldi_nl_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE $input_split_audio_files_condition_false $input_split_audio_files_symbol >> $kaldi_nl_nohup &
else
    echo "1 --> Skipped"
fi


if [ $whisper_t -eq 1 ]
then
    echo "+-+ 2. WHISPER-TIMESTAMPED" $(date)
    mkdir -p $whisper_t_output $whisper_t_output_std
    nohup time $PROJECT/scripts/run_whisper_t.sh $WHISPER_T_PATH $input_audio_files $input_audio_files_extension $whisper_t_output $whisper_t_decoded_extension $WHISPER_T_MODEL $WHISPER_T_MODELS $WHISPER_T_LANG $WHISPER_T_PROMPTS_PATH $whisper_t_remove_ids $whisper_t_unk_symbol $whisper_t_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE $input_split_audio_files_condition_false $input_split_audio_files_symbol >> $whisper_t_nohup &
else
    echo "2 --> Skipped"
fi


if [ $w2v2_gpu -eq 1 ]
then
    echo "+-+ 3. WAV2VEC2.0" $(date)
    mkdir -p $w2v2_gpu_output $w2v2_gpu_output_std
    nohup time $PROJECT/scripts/run_w2v2_gpu.sh $input_audio_files $input_audio_files_extension $w2v2_gpu_output $w2v2_gpu_decoded_extension $W2V2_GPU_REPO $W2V2_GPU_SOURCE $W2V2_GPU_KEEP_ALIVE $w2v2_gpu_remove_ids $w2v2_gpu_unk_symbol $w2v2_gpu_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE $input_split_audio_files_condition_false $input_split_audio_files_symbol >> $w2v2_gpu_nohup &
else
    echo "3 --> Skipped"
fi

if [ $kaldi_custom_v2_2022 -eq 1 ]
then
    echo "+-+ 4. KALDI_CUSTOM: HoMed-v2_2022" $(date)
    mkdir -p $kaldi_custom_v2_2022_output $kaldi_custom_v2_2022_output_files $kaldi_custom_v2_2022_output_std
    nohup time $PROJECT/scripts/run_custom_kaldi.sh $kaldi_custom_v2_2022_output_files $KALDI_CGN $kaldi_custom_am_models_v2_2022 $input_split_audio_files $input_split_audio_files_extension $kaldi_custom_v2_2022_beam $kaldi_custom_lm_models_v2_2022 $kaldi_custom_v2_2022_remove_ids $kaldi_custom_v2_2022_unk_symbol $kaldi_custom_v2_2022_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE $input_split_audio_files_condition $input_split_audio_files_symbol >> $kaldi_custom_v2_2022_nohup &
else
    echo "4 --> Skipped"
fi

if [ $kaldi_custom_v1_2023 -eq 1 ]
then
    echo "+-+ 5. KALDI_CUSTOM: HoMed-v1_2023: nivel-cgn.lex + utwente_0.2" $(date)
    mkdir -p $kaldi_custom_v1_2023_output $kaldi_custom_v1_2023_output_files $kaldi_custom_v1_2023_output_std
    nohup time $PROJECT/scripts/run_custom_kaldi.sh $kaldi_custom_v1_2023_output_files $KALDI_CGN $kaldi_custom_am_models_v1_2023 $input_split_audio_files $input_split_audio_files_extension $kaldi_custom_v1_2023_beam $kaldi_custom_lm_models_v1_2023 $kaldi_custom_v1_2023_remove_ids $kaldi_custom_v1_2023_unk_symbol $kaldi_custom_v1_2023_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE $input_split_audio_files_condition $input_split_audio_files_symbol >> $kaldi_custom_v1_2023_nohup &
else
    echo "5 --> Skipped"
fi

if [ $kaldi_custom_v2_2023 -eq 1 ]
then
    echo "+-+ 6. KALDI_CUSTOM: HoMed-v2_2023: nivel-cgn.lex + utwente_0.9" $(date)
    mkdir -p $kaldi_custom_v2_2023_output $kaldi_custom_v2_2023_output_files $kaldi_custom_v2_2023_output_std
    nohup time $PROJECT/scripts/run_custom_kaldi.sh $kaldi_custom_v2_2023_output_files $KALDI_CGN $kaldi_custom_am_models_v2_2023 $input_split_audio_files $input_split_audio_files_extension $kaldi_custom_v2_2023_beam $kaldi_custom_lm_models_v2_2023 $kaldi_custom_v2_2023_remove_ids $kaldi_custom_v2_2023_unk_symbol $kaldi_custom_v2_2023_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE $input_split_audio_files_condition $input_split_audio_files_symbol >> $kaldi_custom_v2_2023_nohup &
else
    echo "6 --> Skipped"
fi



echo
echo
echo "WER: Once all ASR systems are done, you might run:"
echo "$PROJECT/scripts/utils/summary_sclite.sh $PROJECT_OUTPUT $PROJECT_OUTPUT/summary.txt"
echo
echo $(date)
echo "++ uber.sh script finished correctly ++"
echo


###raw_input_audio_files=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_audio_data
###raw_input_audio_files=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/homed_wav
###raw_input_audio_files=/vol/tensusers4/ctejedor/shared/stcart/virtask-s1/converted
###raw_input_audio_files=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_arjan
###raw_input_audio_files=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_2 # Path to your raw audio data
###input_transcriptions_ground_truth=$PROJECT/raw_transcriptions
###input_transcriptions_ground_truth=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/ctmator/ref_original
###input_transcriptions_ground_truth=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_arjan