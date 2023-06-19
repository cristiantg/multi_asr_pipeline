#!/bin/bash

# Mandatory first:
# ssh thunderlane
# lamachine-lanewcristianmachine-activate
# cd /vol/tensusers/ctejedor/multi_asr_pipeline/scripts/utils/
# nohup time ./finetune_kaldi.sh &

cwd=$(pwd)

KALDIdir=/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl
final_lm_filename=nivel-cgn-utwente_0.2
final_lm=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/LM/$final_lm_filename
final_lexicon=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/lexicon/nivel-cgn.lex
phones_filename=phones.txt
model=/vol/tensusers/ctejedor/homed_nivel/HoMed_models_final/AM/tdnn1a_sp_bi_online/
phones=$model/$phones_filename
graphloc=$model
graph_options=$(cat ${model}/*.info | sed -n '/\[Graph_options\]/{:a;n;/^\[/q;p;ba}')


lm_ext=.gz
final_lm_compressed=$final_lm_filename$lm_ext
if [ ! -f $cwd/$final_lm_compressed ]; then
    echo "LM not found, compressing (takes 7 minutes approx. with CGN)..."
    cp $final_lm .
    gzip ./$final_lm_filename
fi

if [ ! -f $final_lexicon ]; then
    echo "Lexicon not found"
    exit 2
fi


echo
echo "final_lexicon: "$final_lexicon
echo "final_lm_compressed: "$cwd/$final_lm_compressed

## LGdir construction
LGdir=$cwd/LGdir && rm -rf $LGdir && mkdir $LGdir
cp $phones $LGdir
chmod 755 $LGdir/$phones_filename
cd $KALDIdir
. $KALDIdir/path.sh
echo
echo "++ Arpa2LG.sh --> Takes 7 mins if full-CGN"
echo $(date)
local/Arpa2LG.sh $cwd/$final_lm_compressed $final_lexicon $LGdir


HCLGdir=$cwd/graph_s && cd $KALDIdir
echo 
echo "++ mkgraph.sh --> Takes 2.5 hours if full-CGN"
echo $(date)
echo $model $graph_options $LGdir $graphloc $HCLGdir
utils/mkgraph.sh $graph_options $LGdir $graphloc $HCLGdir