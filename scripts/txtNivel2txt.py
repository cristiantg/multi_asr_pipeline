import os
import re
import shutil

input_folder_path = 'absoulte-path-source-folder'
output_folder_path = 'absoulte-path-output-folder'

def process_files(input_folder, output_folder):
    txt_files = [f for f in os.listdir(input_folder) if f.endswith('.txt')]

    for txt_file in txt_files:
        input_file_path = os.path.join(input_folder, txt_file)
        with open(input_file_path, 'r') as f:
            content = f.read()

        prompts = re.findall(r'\[Speaker:\s*(.*?)\]\s*(.*?)\s*\[EndTime:\s*\d+ms\]', content, re.DOTALL)
        new_file_name = f"{os.path.splitext(txt_file)[0]}.prompt"
        new_file_path = os.path.join(output_folder, new_file_name)
        if prompts:
            with open(new_file_path, 'w') as new_file:
                for speaker, prompt in prompts:
                    new_file.write(f"{prompt.strip()}\n")
        
            #print(f"Processed {txt_file}. Created 1 prompt file.")
        else:
            print(f"No prompts found in {txt_file}.")
            with open(new_file_path, 'w') as new_file:
                new_file.write(f"{content.strip()}\n")



# Create the output folder if it doesn't exist
os.makedirs(output_folder_path, exist_ok=True)

process_files(input_folder_path, output_folder_path)
