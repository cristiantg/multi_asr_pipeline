import sys, os

TOTAL_ARGS_PLUS_ONE=5+1
if len(sys.argv) != TOTAL_ARGS_PLUS_ONE:
    print(sys.argv[0] + "Please, specify "+str(TOTAL_ARGS_PLUS_ONE-1)+" parameters: input_audio_folder, output_folder, segments_file_path, extension_audio_files, SEP_segments")
    # python3 ctm2txt.py INPUT_FILE OUTPUT_DIR .txt CTMATOR_PATH LEXICONATOR_PATH
    sys.exit(2)
[input_folder, output_folder, segments_file_path, extension, SEP] = sys.argv[1:TOTAL_ARGS_PLUS_ONE]
sample_rate=16000
bit_depth=16
channels=1
pad=0.3
vol=0.1

def audio_files_in_folder(folder_path, extension):
    ids=[]
    # Check if the specified path is a directory
    if not os.path.isdir(folder_path):
        print(f"Error: '{folder_path}' is not a valid directory.")
        return ids
    
    # Get the list of files in the folder
    files = os.listdir(folder_path)
    
    if not files:
        print(f"No files found in '{folder_path}'.")
    else:
        print(f"Audio files in '{folder_path}' with extension '{extension}':")
        for file_name in files:
            file_path = os.path.join(folder_path, file_name)
            if os.path.isfile(file_path) and file_name.endswith(extension):
                ids.append(file_name.rsplit('.', maxsplit=1)[0])
    return ids


def order_data(data):
    order_segments = {}
    for key in data.keys():
        order_keys = sorted(data[key].keys())
        counter=1
        for aux_key in order_keys:
            aux_tuple = data[key][aux_key]
            if key not in order_segments:
                order_segments[key] = {}
            order_segments[key][str(counter).zfill(5)] = aux_tuple
            counter+=1
        #print("wav file:", key)
        #for inner_key in :
        #    print(inner_key, data[key][inner_key])
        #print()
    return order_segments

def extract_data(path, ids):
    with open(path, 'r') as file:
        data = {}
        for line in file:
            columns = line.strip().split()
            #print(columns)
            second_column = columns[1]
            if second_column in ids:
                ####first_column = columns[0] ## We cannot use it beacuse it is not time-ordered
                third_column = float(columns[2])
                fourth_column = float(columns[3])

                ####key_parts = first_column.split('.') ## We cannot use it beacuse it is not time-ordered
                ###key = int(key_parts[-1]) ## We cannot use it beacuse it is not time-ordered
                key = third_column
                
                if second_column not in data:
                    data[second_column] = {}
                
                data[second_column][key] = (third_column, fourth_column)
        return data


def split_audio(segments_dict):
    os.makedirs(output_folder, exist_ok=True)
    print("-> Creating segments files from", len(segments_dict), "input audio files...")
    seg_counter=0
    for audio_file, audio_segments in segments_dict.items():
        input_file = os.path.join(input_folder, audio_file + extension)
        for segment_id, (start_time, end_time) in audio_segments.items():
            output_file = os.path.join(output_folder, f"{audio_file}{SEP}{segment_id}{extension}")
            #duration = str(round(end_time - start_time,3))
            start_time = str(round(start_time,3))
            end_time = str(round(end_time,3))

            # Construct the sox command
            sox_cmd = (
                f'sox -v {vol} "{input_file}" -r {sample_rate} -b {bit_depth} -c {channels} '
                f'"{output_file}" trim {start_time} ={end_time} '
                f'pad {pad} {pad}'
            )
            #print(sox_cmd)
            os.system(sox_cmd)
            seg_counter+=1
            print(str(seg_counter), end=" ")
            #print(f"Segment {segment_id} of {audio_file} processed. Output file: {output_file}")
    print("\n-> Segments created:", str(seg_counter))
    return None

split_audio(order_data(extract_data(segments_file_path, ids=audio_files_in_folder(input_folder, extension))))