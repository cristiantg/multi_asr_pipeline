#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 input_dir input_ext output_dir output_ext split_symbol"
  exit 1
fi
input_dir="$1"
input_ext="$2"
output_dir="$3"
output_ext="$4"
split_symbol="$5"

# Silence is detected when the audio level drops below 1% for at least 0.3 seconds
X=0.3
Y=1
# 0.3s of silence at the beginning and end of each split file for better ASR performance
SOX_SIL_PAD=0.3 
# SOX: -v 0.1
SOX_VOL=0.1

output_dir_temp=$output_dir-tmp
rm -rf $output_dir_temp # We need a total new one to avoid previous files
mkdir -p "$output_dir" "$output_dir_temp"
COUNTER=0
echo -n "Input files: "
for file in "$input_dir"/*$input_ext; do
  filename=$(basename "$file" $input_ext)
    sox "$file" "$output_dir_temp/$filename$split_symbol%n$output_ext" silence 1 $X $Y% 1 $X $Y% pad $SOX_SIL_PAD $SOX_SIL_PAD : newfile : restart
    COUNTER=$[$COUNTER +1]
    echo -n "$COUNTER "
done

echo
echo "Changing the volume of all files split..."
for file in "$output_dir_temp"/*$output_ext; do
  filename=$(basename "$file" $output_ext)
    sox -v $SOX_VOL "$file" "$output_dir/$filename$output_ext"
done
rm -rf $output_dir_temp

echo
echo -n "Total segments files extracted from the input files: "
ls $output_dir | wc -l