#!/bin/bash

echo "Starting the script..."

shopt -s nocaseglob
shopt -s globstar

FORCE=0
TARGET_FOLDER="$1"

echo "Target folder is: $TARGET_FOLDER"

for arg in "$@"; do
    if [ "$arg" = "--force" ] || [ "$arg" = "-F" ]; then
        FORCE=1
    fi
done

srcdir="."

if [[ -z $TARGET_FOLDER ]]; then
    files=("$srcdir"/*.[wW][aA][vV])
else
    files=("$srcdir/$TARGET_FOLDER"/**/*.[wW][aA][vV])
fi

echo "Files to process:"
echo "${files[@]}"

for file in "${files[@]}"; do
    if [[ -f $file ]]; then
        echo "Processing $file..."
        
        rel_path="${file#"$srcdir/"}"
        base_dir=$(dirname "$rel_path")
        base_name=$(basename "${file,,}" .wav)

        mkdir -p "$srcdir/squid_16bit_441kz/$base_dir"
        mkdir -p "$srcdir/morphagene_32bit_48khz/$base_dir"
        mkdir -p "$srcdir/disting_16bit_96khz/$base_dir"

        if [ $FORCE -eq 1 ]; then
            echo "Force converting $file..."
            ffmpeg -y -i "$file" -acodec pcm_s16le -ar 44100 "$srcdir/squid_16bit_441kz/$base_dir/${base_name}.wav"
            ffmpeg -y -i "$file" -acodec pcm_s32le -ar 48000 "$srcdir/morphagene_32bit_48khz/$base_dir/${base_name}.wav"
            ffmpeg -y -i "$file" -acodec pcm_s16le -ar 96000 "$srcdir/disting_16bit_96khz/$base_dir/${base_name}.wav"
        else
            echo "Standard converting $file..."
            [ ! -f "$srcdir/squid_16bit_441kz/$base_dir/${base_name}.wav" ] && ffmpeg -n -i "$file" -acodec pcm_s16le -ar 44100 "$srcdir/squid_16bit_441kz/$base_dir/${base_name}.wav"
            [ ! -f "$srcdir/morphagene_32bit_48khz/$base_dir/${base_name}.wav" ] && ffmpeg -n -i "$file" -acodec pcm_s32le -ar 48000 "$srcdir/morphagene_32bit_48khz/$base_dir/${base_name}.wav"
            [ ! -f "$srcdir/disting_16bit_96khz/$base_dir/${base_name}.wav" ] && ffmpeg -n -i "$file" -acodec pcm_s16le -ar 96000 "$srcdir/disting_16bit_96khz/$base_dir/${base_name}.wav"
        fi
    fi
done

echo "Finished processing files."

shopt -u nocaseglob
shopt -u globstar
