#!/bin/bash

shopt -s nocaseglob

FORCE=0
for arg in "$@"; do
    if [ "$arg" = "--force" ] || [ "$arg" = "-F" ]; then
        FORCE=1
    fi
done

srcdir=${1%/}

mkdir -p "$srcdir/squid_16bit_441kz" "$srcdir/morphagene_32bit_48khz" "$srcdir/disting_16bit_96khz"

if [ ! -d "$srcdir/squid_16bit_441kz" ] || [ ! -d "$srcdir/morphagene_32bit_48khz" ] || [ ! -d "$srcdir/disting_16bit_96khz" ]
then
  echo "Failed to create output directories, please check permissions."
  exit 1
fi

for file in "$srcdir"/*.[wW][aA][vV]; do
    base=$(basename "${file,,}" .wav)

    if [ $FORCE -eq 1 ]; then
        ffmpeg -y -i "$file" -acodec pcm_s16le -ar 44100 "$srcdir/squid_16bit_441kz/${base}.wav"
        ffmpeg -y -i "$file" -acodec pcm_s32le -ar 48000 "$srcdir/morphagene_32bit_48khz/${base}.wav"
        ffmpeg -y -i "$file" -acodec pcm_s16le -ar 96000 "$srcdir/disting_16bit_96khz/${base}.wav"
    elif [ ! -f "$srcdir/squid_16bit_441kz/${base}.wav" ]; then
        ffmpeg -n -i "$file" -acodec pcm_s16le -ar 44100 "$srcdir/squid_16bit_441kz/${base}.wav"
    elif [ ! -f "$srcdir/morphagene_32bit_48khz/${base}.wav" ]; then
        ffmpeg -n -i "$file" -acodec pcm_s32le -ar 48000 "$srcdir/morphagene_32bit_48khz/${base}.wav"
    elif [ ! -f "$srcdir/disting_16bit_96khz/${base}.wav" ]; then
        ffmpeg -n -i "$file" -acodec pcm_s16le -ar 96000 "$srcdir/disting_16bit_96khz/${base}.wav"
    fi
done

shopt -u nocaseglob

