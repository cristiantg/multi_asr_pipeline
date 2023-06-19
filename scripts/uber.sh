#!/bin/sh

#!! SEE TODOs
# !! NORMALIZE WITH SOX ALL AUIDO FILES FIRST: utils/normalize_audio.sh

# input: 
# output:

# ssh thunderlane
# project=/vol/tensusers/ctejedor/multi_asr_pipeline/scripts && cd $project && clear && pwd
# vim uber.sh #change the paths of the CONSTANTS accordingly
# ./uber.sh

# Requires
# 1. A pony with a GPU on Ponyland and:
# KALDI_NL: /vol/customopt/lamachine.stable
# SCLITE: $KALDI_NL/opt/kaldi/tools/sctk/bin/sclite
# 2. Github repositories:
# CTMATOR: https://github.com/cristiantg/ctmator/
# LEXICONATOR: https://github.com/cristiantg/lexiconator
# KALDI_CGN: https://github.com/cristiantg/kaldi_egs_CGN/tree/onPonyLand


############################### CONSTANTS ###############################
# I. Must exist
# Steps mega pipeline: [0-1] -> 1 Run, 0 Skip.
prepare_ref=0; kaldi_nl=0; whisper_t=0; w2v2=1; kaldi_custom_v2_2022=0; kaldi_custom_v1_2023=0; kaldi_custom_v2_2023=0

PROJECT=/vol/tensusers/ctejedor/multi_asr_pipeline
###input_audio_files=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_audio_data
input_audio_files=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_2
###input_audio_files=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_3
input_audio_files_extension=.wav
###input_transcriptions_ground_truth=$PROJECT/raw_transcriptions
input_transcriptions_ground_truth=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/ctmator/ref_original
input_transcriptions_ground_truth_extension=.ctm
input_transcriptions_ground_truth_std=$PROJECT/transcriptions
input_transcriptions_ground_truth_std_extension=.txt
input_transcriptions_ground_truth_std_remove_ids="3"
input_transcriptions_ground_truth_std_unk_symbol="<unk>"
KALDI_NL_PATH=/vol/customopt/lamachine.stable/opt/kaldi_nl
KALDI_LM_PATH=/vol/customopt/lamachine.stable/opt/kaldi
SCLITE=$KALDI_LM_PATH/tools/sctk/bin/sclite 
CTMATOR=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/ctmator
LEXICONATOR=/home/ctejedor/python-scripts/lexiconator
KALDI_CGN=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi/egs/kaldi_egs_CGN/s5

kaldi_nl_remove_ids="1" # remove ids at the end of the sentence
kaldi_nl_unk_symbol="<unk>"
WHISPER_T_PATH=/vol/tensusers5/ctejedor/whisper
WHISPER_T_MODEL=large
WHISPER_T_MODELS=$WHISPER_T_PATH/models
WHISPER_T_LANG=nl
WHISPER_T_PROMPTS_PATH=0
whisper_t_remove_ids="2" # extract "text" from json
whisper_t_unk_symbol="<unk>"
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
PROJECT_OUTPUT=$PROJECT/output
OUTPUT_STANDARD_TXT=output_std
OUTPUT_STANDARD_TXT_EXTENSION=.txt
OUTPUT_REF_FILE=$PROJECT_OUTPUT/ref.txt
kaldi_nl_output=$PROJECT_OUTPUT/kaldi_nl
kaldi_nl_output_std=$kaldi_nl_output/$OUTPUT_STANDARD_TXT
kaldi_nl_decoded_extension=.txt
kaldi_nl_nohup=$kaldi_nl_output/kaldi_nl_nohup.out
whisper_t_output=$PROJECT_OUTPUT/whisper_t
whisper_t_output_std=$whisper_t_output/$OUTPUT_STANDARD_TXT
whisper_t_decoded_extension=.json
whisper_t_nohup=$whisper_t_output/whisper_t_nohup.out
kaldi_custom_v2_2022_output=$PROJECT_OUTPUT/kaldi_custom_v2_2022
kaldi_custom_v2_2022_nohup=$kaldi_custom_v2_2022_output/kaldi_custom_v2_2022_nohup.out
kaldi_custom_v2_2022_output_files=$kaldi_custom_v2_2022_output/decoded
kaldi_custom_v2_2022_beam=20
kaldi_custom_v2_2022_output_std=$kaldi_custom_v2_2022_output/$OUTPUT_STANDARD_TXT
kaldi_custom_v1_2023_output=$PROJECT_OUTPUT/kaldi_custom_v1_2023
kaldi_custom_v1_2023_nohup=$kaldi_custom_v1_2023_output/kaldi_custom_v1_2023_nohup.out
kaldi_custom_v1_2023_output_files=$kaldi_custom_v1_2023_output/decoded
kaldi_custom_v1_2023_beam=20
kaldi_custom_v1_2023_output_std=$kaldi_custom_v1_2023_output/$OUTPUT_STANDARD_TXT
kaldi_custom_v2_2023_output=$PROJECT_OUTPUT/kaldi_custom_v2_2023
kaldi_custom_v2_2023_nohup=$kaldi_custom_v2_2023_output/kaldi_custom_v2_2023_nohup.out
kaldi_custom_v2_2023_output_files=$kaldi_custom_v2_2023_output/decoded
kaldi_custom_v2_2023_beam=20
kaldi_custom_v2_2023_output_std=$kaldi_custom_v2_2023_output/$OUTPUT_STANDARD_TXT
############################### CONSTANTS ###############################



echo
echo $(date)
echo "++ uber.sh script (Each step is run in the background) ++"
echo
mkdir -p $PROJECT_OUTPUT && rm -r __pycache__


if [ $prepare_ref -eq 1 ]
then
    echo "0. SCLITE ref file preparation" $(date)
    # Takes the "raw CTM transcription files" and prepares a single ref.file with all txt files in "transcriptions" folder
    python3 -c "from normalize_output import process_audio; process_audio('$input_audio_files', '$input_audio_files_extension','$input_transcriptions_ground_truth', '$input_transcriptions_ground_truth_extension','$input_transcriptions_ground_truth_std_remove_ids', '$input_transcriptions_ground_truth_std_unk_symbol','$input_transcriptions_ground_truth_std', '$input_transcriptions_ground_truth_std_extension', '$CTMATOR', '$LEXICONATOR')"
    python3 txt2sclite.py $input_transcriptions_ground_truth_std $OUTPUT_REF_FILE $input_transcriptions_ground_truth_std_extension
else
    echo "0 --> Skipped"
fi


if [ $kaldi_nl -eq 1 ]
then
    echo "1. KALDI_NL" $(date)
    rm -rf $kaldi_nl_output/* $kaldi_nl_output_std/* && mkdir -p $kaldi_nl_output $kaldi_nl_output_std
    nohup time ./run_kaldi_nl.sh $KALDI_LM_PATH $KALDI_NL_PATH $input_audio_files $input_audio_files_extension $kaldi_nl_output $kaldi_nl_decoded_extension $kaldi_nl_remove_ids $kaldi_nl_unk_symbol $kaldi_nl_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE >> $kaldi_nl_nohup &
else
    echo "1 --> Skipped"
fi


if [ $whisper_t -eq 1 ]
then
    echo "2. WHISPER-TIMESTAMPED" $(date)
    rm -rf $whisper_t_output/* $whisper_t_output_std/* && mkdir -p $whisper_t_output $whisper_t_output_std
    nohup time ./run_whisper_t.sh $WHISPER_T_PATH $input_audio_files $input_audio_files_extension $whisper_t_output $whisper_t_decoded_extension $WHISPER_T_MODEL $WHISPER_T_MODELS $WHISPER_T_LANG $WHISPER_T_PROMPTS_PATH $whisper_t_remove_ids $whisper_t_unk_symbol $whisper_t_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE >> $whisper_t_nohup &
else
    echo "2 --> Skipped"
fi


if [ $w2v2 -eq 1 ]
then
    echo "3. WAV2VEC2.0" $(date)
else
    echo "3 --> Skipped"
fi

if [ $kaldi_custom_v2_2022 -eq 1 ]
then
    echo "4. KALDI_CUSTOM: HoMed-v2_2022" $(date)
    rm -rf $kaldi_custom_v2_2022_output/* $kaldi_custom_v2_2022_output_std/* && mkdir -p $kaldi_custom_v2_2022_output $kaldi_custom_v2_2022_output_files $kaldi_custom_v2_2022_output_std
    nohup time ./run_custom_kaldi.sh $kaldi_custom_v2_2022_output_files $KALDI_CGN $kaldi_custom_am_models_v2_2022 $input_audio_files $input_audio_files_extension $kaldi_custom_v2_2022_beam $kaldi_custom_lm_models_v2_2022 $kaldi_custom_v2_2022_remove_ids $kaldi_custom_v2_2022_unk_symbol $kaldi_custom_v2_2022_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE >> $kaldi_custom_v2_2022_nohup &
else
    echo "4 --> Skipped"
fi

if [ $kaldi_custom_v1_2023 -eq 1 ]
then
    echo "5. KALDI_CUSTOM: HoMed-v1_2023: nivel-cgn.lex + utwente_0.2" $(date)
    rm -rf $kaldi_custom_v1_2023_output/* $kaldi_custom_v1_2023_output_std/* && mkdir -p $kaldi_custom_v1_2023_output $kaldi_custom_v1_2023_output_files $kaldi_custom_v1_2023_output_std
    nohup time ./run_custom_kaldi.sh $kaldi_custom_v1_2023_output_files $KALDI_CGN $kaldi_custom_am_models_v1_2023 $input_audio_files $input_audio_files_extension $kaldi_custom_v1_2023_beam $kaldi_custom_lm_models_v1_2023 $kaldi_custom_v1_2023_remove_ids $kaldi_custom_v1_2023_unk_symbol $kaldi_custom_v1_2023_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE >> $kaldi_custom_v1_2023_nohup &
else
    echo "5 --> Skipped"
fi

if [ $kaldi_custom_v2_2023 -eq 1 ]
then
    echo "6. KALDI_CUSTOM: HoMed-v2_2023: nivel-cgn.lex + utwente_0.9" $(date)
    rm -rf $kaldi_custom_v2_2023_output/* $kaldi_custom_v2_2023_output_std/* && mkdir -p $kaldi_custom_v2_2023_output $kaldi_custom_v2_2023_output_files $kaldi_custom_v2_2023_output_std
    nohup time ./run_custom_kaldi.sh $kaldi_custom_v2_2023_output_files $KALDI_CGN $kaldi_custom_am_models_v2_2023 $input_audio_files $input_audio_files_extension $kaldi_custom_v2_2023_beam $kaldi_custom_lm_models_v2_2023 $kaldi_custom_v2_2023_remove_ids $kaldi_custom_v2_2023_unk_symbol $kaldi_custom_v2_2023_output_std $OUTPUT_STANDARD_TXT_EXTENSION $CTMATOR $LEXICONATOR $SCLITE $OUTPUT_REF_FILE >> $kaldi_custom_v2_2023_nohup &
else
    echo "6 --> Skipped"
fi



echo
echo
echo $(date)
echo "++ uber.sh script finished correctly ++"
echo
### utils/summary_sclite.sh ../output ../output/summary.txt