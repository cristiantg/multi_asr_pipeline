#!/bin/sh

# input: 
# output:

# ssh thunderlane
# project=/vol/tensusers/ctejedor/multi_asr_pipeline/scripts && cd $project && clear && pwd
# vim uber.sh #change the paths of the CONSTANTS accordingly
# ./uber.sh

# Requires
# A pony with GPU on Ponyland
# KALDI_NL (e.g., /vol/customopt/lamachine.stable)
# CTMATOR:https://github.com/cristiantg/ctmator/
# LEXICONATOR: https://github.com/cristiantg/lexiconator
# KALDI_CGN: https://github.com/cristiantg/kaldi_egs_CGN/tree/onPonyLand

############################### CONSTANTS ###############################
# I. Must exist
PROJECT=/vol/tensusers/ctejedor/multi_asr_pipeline
input_audio_files=/vol/tensusers/ctejedor/multi_asr_pipeline/raw_audio_data
input_audio_files_extension=.wav
KALDI_NL_PATH=/vol/customopt/lamachine.stable/opt/kaldi_nl
CTMATOR=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/ctmator
LEXICONATOR=/home/ctejedor/python-scripts/lexiconator
KALDI_CUSTOM_PATH=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi
KALDI_CGN=$KALDI_CUSTOM_PATH/egs/kaldi_egs_CGN/s5

kaldi_custom_am_models_v2_2022=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/models/NL/UTwente/HMI/AM/CGN_all/nnet3_online/tdnn/v1.0
kaldi_custom_lm_models_v2_2022=/vol/tensusers3/ctejedor/lrec_homed/homed_90_run6/out_cgn
kaldi_custom_am_models_v1_2023=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/AM/tdnn1a_sp_bi_online
kaldi_custom_lm_models_v1_2023=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/AM/tdnn1a_sp_bi_online/graph_s
# TODO-Change with the LM adaptation, tomorrow
kaldi_custom_am_models_v2_2023=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/AM/tdnn1a_sp_bi_online
kaldi_custom_lm_models_v2_2023=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/AM/tdnn1a_sp_bi_online/graph_s


# II. Generated (no need to change)
PROJECT_OUTPUT=$PROJECT/output2
OUTPUT_STANDARD_TXT=output_std

kaldi_custom_v2_2022_output=$PROJECT_OUTPUT/kaldi_custom_v2_2022
kaldi_custom_v2_2022_nohup=$kaldi_custom_v2_2022_output/kaldi_custom_v2_2022_nohup.out
kaldi_custom_v2_2022_output_files=$kaldi_custom_v2_2022_output/decoded
kaldi_custom_v2_2022_beam=1 #TODO-Change
kaldi_custom_v2_2022_output_std=$kaldi_custom_v2_2022_output/$OUTPUT_STANDARD_TXT
kaldi_custom_v1_2023_output=$PROJECT_OUTPUT/kaldi_custom_v1_2023
kaldi_custom_v1_2023_nohup=$kaldi_custom_v1_2023_output/kaldi_custom_v1_2023_nohup.out
kaldi_custom_v1_2023_output_files=$kaldi_custom_v1_2023_output/decoded
kaldi_custom_v1_2023_beam=1 #TODO-Change
kaldi_custom_v1_2023_output_std=$kaldi_custom_v1_2023_output/$OUTPUT_STANDARD_TXT
kaldi_custom_v2_2023_output=$PROJECT_OUTPUT/kaldi_custom_v2_2023
kaldi_custom_v2_2023_nohup=$kaldi_custom_v2_2023_output/kaldi_custom_v2_2023_nohup.out
kaldi_custom_v2_2023_output_files=$kaldi_custom_v2_2023_output/decoded
kaldi_custom_v2_2023_beam=1 #TODO-Change
kaldi_custom_v2_2023_output_std=$kaldi_custom_v2_2023_output/$OUTPUT_STANDARD_TXT
############################### CONSTANTS ###############################



# TODO-RECOVER
echo
echo "0. SCLITE ref file preparation" $(date)
mkdir -p $PROJECT_OUTPUT

echo "1. KALDI_NL" $(date)

echo "2. WHISPER-TIMESTAMPED" $(date)

echo "3. WAV2VEC2.0" $(date)

echo "4. KALDI_CUSTOM: HoMed-v2_2022" $(date)
rm -rf $kaldi_custom_v2_2022_output/* $kaldi_custom_v2_2022_output_std/* && mkdir -p $kaldi_custom_v2_2022_output $kaldi_custom_v2_2022_output_files $kaldi_custom_v2_2022_output_std
nohup time ./run_custom_kaldi.sh $kaldi_custom_v2_2022_output_files $KALDI_CGN $kaldi_custom_am_models_v2_2022 $input_audio_files $input_audio_files_extension $kaldi_custom_v2_2022_beam $kaldi_custom_lm_models_v2_2022 >> $kaldi_custom_v2_2022_nohup &

echo "5. KALDI_CUSTOM: HoMed-v1_2023" $(date)
rm -rf $kaldi_custom_v1_2023_output/* $kaldi_custom_v1_2023_output_std/* && mkdir -p $kaldi_custom_v1_2023_output $kaldi_custom_v1_2023_output_files $kaldi_custom_v1_2023_output_std
nohup time ./run_custom_kaldi.sh $kaldi_custom_v1_2023_output_files $KALDI_CGN $kaldi_custom_am_models_v1_2023 $input_audio_files $input_audio_files_extension $kaldi_custom_v1_2023_beam $kaldi_custom_lm_models_v1_2023 >> $kaldi_custom_v1_2023_nohup &
exit 0

echo "6. KALDI_CUSTOM: HoMed-v2_2023" $(date)
rm -rf $kaldi_custom_v2_2023_output/* $kaldi_custom_v2_2023_output_std/* && mkdir -p $kaldi_custom_v2_2023_output $kaldi_custom_v2_2023_output_files $kaldi_custom_v2_2023_output_std
nohup time ./run_custom_kaldi.sh $kaldi_custom_v2_2023_output_files $KALDI_CGN $kaldi_custom_am_models_v2_2023 $input_audio_files $input_audio_files_extension $kaldi_custom_v2_2023_beam $kaldi_custom_lm_models_v2_2023 >> $kaldi_custom_v2_2023_nohup &



echo
echo
echo $(date)
echo "++ uber.sh script finished correctly ++"
echo