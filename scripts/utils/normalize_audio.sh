#!/bin/bash

# Specify the input and output directories
input_dir="/vol/tensusers4/ctejedor/lanewcristianmachine/opt/kaldi_nl/homed_wav_3"
output_dir="/vol/tensusers/ctejedor/multi_asr_pipeline/raw_3"

# Iterate over each WAV file in the input directory
for file in "$input_dir"/*.wav; do
  # Extract the filename without the extension
  filename=$(basename "$file" .wav)
  
  # Construct the output filename with the desired sample rate
  output_file="$output_dir/$filename.wav"
  
  # Use SoX to perform the sample rate conversion
  sox "$file" -r 16000 "$output_file"
  
  echo "Converted: $file"
done

