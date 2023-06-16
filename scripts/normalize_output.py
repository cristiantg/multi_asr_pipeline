import os

def __list_files_with_extension(input_folder, extension):
    file_list = []
    for root, dirs, files in os.walk(input_folder):
        for file in files:
            if file.endswith(extension):
                file_list.append(os.path.join(root, file))
    return file_list

# REMOVE_IDS=0 (No), REMOVE_IDS=1 (Yes), REMOVE_IDS=2 (Extract "text" from json), REMOVE_IDS=3 (ctm to txt)
def __read_files_write_content(file_list, extension, decoded_folder, output_path, output_extension, CTMATOR, LEXICONATOR, REMOVE_IDS=0, UNK_SYMBOL="<unk>"):
    REMOVE_IDS=int(REMOVE_IDS)
    for file_path in file_list:
        read_file_path = os.path.join(decoded_folder, os.path.basename(file_path).rsplit('.', maxsplit=1)[0] + extension)
        try:
            with open(read_file_path, 'r') as read_file:
                hyp = ""             
                if REMOVE_IDS==3:                
                    os.system("python3 ctm2txt.py "+read_file_path+ " "+output_path+" "+ output_extension)
                elif REMOVE_IDS==2:
                    print("JSON")
                    print("Now I call the cleaner(hyp)")
                elif REMOVE_IDS==1:
                    print("Remove (ID)")
                    print("Now I call the cleaner(hyp)")
                else:
                    print("Just join lines")
                    print("Now I call the cleaner(hyp)")
        except FileNotFoundError:
            print(f"File {read_file_path} not found.")
        except Exception as e:
            print(f"An error occurred while reading {read_file_path}: {str(e)}")



def process_audio(audio_path, audio_extension, transcripts_folder_path, transcripts_extension, REMOVE_IDS, UNK_SYMBOL, output_path, output_extension, CTMATOR, LEXICONATOR):
    __read_files_write_content(__list_files_with_extension(audio_path, audio_extension), transcripts_extension, transcripts_folder_path, output_path, output_extension, CTMATOR, LEXICONATOR, REMOVE_IDS, UNK_SYMBOL)