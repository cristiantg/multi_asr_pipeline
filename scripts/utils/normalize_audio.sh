#!/bin/bash

# echo "--> Note: Best decoding options: short utterances,
# SOX: -v 0.1, 16k 
# ubser_single.sh: --frame-shift:0.03, no inv-acoustic-scale parameter"

if [[ "$#" -ne 4 ]]; then
  echo "Usage: $0 <input_dir> <output_dir> <input_input_ext: .wav> <output_input_ext: .wav>"
  exit 1
fi
input_dir="$1"
output_dir="$2"
input_ext="$3"
output_ext="$4"
SOX_VOL=0.1
SOX_KHZ=16000
SOX_CHANNELS=1
SOX_BITS=16
mkdir -p $output_dir

COUNTER=0
for file in "$input_dir"/*$input_ext; do
  filename=$(basename "$file" $input_ext)
  output_file="$output_dir/$filename$output_ext"
  sox -v $SOX_VOL "$file" -r $SOX_KHZ -c $SOX_CHANNELS -b $SOX_BITS "$output_file"
  #echo "Converted: $file"
  COUNTER=$[$COUNTER +1]
  echo -n "$COUNTER "
done

echo
echo "$COUNTER files normalized with SOX"