#!/bin/bash
#
# This script is meant to be run from the parent directory.
#
# Requres SoX
#
# brew install sox --with-libsndfile
#

IN=wav
OUT=gen

mkdir -p $OUT

caf_data_formats=( I8 ulaw alaw BEI16 BEI24 BEI32 BEF32 BEF64 LEI16 LEI24 LEI32 LEF32 LEF64 )

# TODO:
# WAV: IMA-ADPCM 
# WAV: MS-ADPCM
# CAF: IMA4 

# CAF files (requires afconvert - SoX (14.4.2) doesn't create 64-bit floating-point CAF files correctly)
if command -v afconvert >/dev/null 2>&1; then
    echo ${0##*/}: Generating CAF sounds...

    for channels in `seq 1 2`;
    do
        for data_format in "${caf_data_formats[@]}"
        do
            afconvert -f caff -c $channels -d $data_format $IN/sound.wav $OUT/sound-${data_format}-${channels}ch.caf
        done
    
        # CAF-only raw files
        sox $OUT/sound-I8-${channels}ch.caf $OUT/sound-I8-${channels}ch.raw
        sox $OUT/sound-ulaw-${channels}ch.caf --endian little --encoding signed-integer --bits 16 --channels $channels $OUT/sound-ulaw-${channels}ch.raw
        sox $OUT/sound-alaw-${channels}ch.caf --endian little --encoding signed-integer --bits 16 --channels $channels $OUT/sound-alaw-${channels}ch.raw    
    done
fi

echo ${0##*/}: Generating WAV sounds...
for channels in `seq 1 2`;
do
    # 8-bit WAVE files
    # Note that ulaw/alaw encoder for WAVE has slightly different output than the one for CAF, so it needs a seperate RAW file.
    sox $IN/sound.wav --encoding unsigned-integer --bits 8 --channels $channels $OUT/sound-UI8-${channels}ch.wav
    sox $IN/sound.wav --encoding mu-law --bits 8 --channels $channels $OUT/sound-ulaw-wav-${channels}ch.wav
    sox $IN/sound.wav --encoding a-law --bits 8 --channels $channels $OUT/sound-alaw-wav-${channels}ch.wav
    
    # 8-bit RAW files
    sox $OUT/sound-UI8-${channels}ch.wav --channels $channels $OUT/sound-UI8-${channels}ch.raw
    sox $OUT/sound-ulaw-wav-${channels}ch.wav --endian little --encoding signed-integer --bits 16 --channels $channels $OUT/sound-ulaw-wav-${channels}ch.raw
    sox $OUT/sound-alaw-wav-${channels}ch.wav --endian little --encoding signed-integer --bits 16 --channels $channels $OUT/sound-alaw-wav-${channels}ch.raw
    
    # Little endian WAVE files
    sox $IN/sound.wav --endian little --encoding signed-integer --bits 16 --channels $channels $OUT/sound-LEI16-${channels}ch.wav
    sox $IN/sound.wav --endian little --encoding signed-integer --bits 24 --channels $channels $OUT/sound-LEI24-${channels}ch.wav
    sox $IN/sound.wav --endian little --encoding signed-integer --bits 32 --channels $channels $OUT/sound-LEI32-${channels}ch.wav
    sox $IN/sound.wav --endian little --encoding floating-point --bits 32 --channels $channels $OUT/sound-LEF32-${channels}ch.wav
    sox $IN/sound.wav --endian little --encoding floating-point --bits 64 --channels $channels $OUT/sound-LEF64-${channels}ch.wav
    
    # Little endian RAW files
    sox $OUT/sound-LEI16-${channels}ch.wav --endian little $OUT/sound-LEI16-${channels}ch.raw
    sox $OUT/sound-LEI24-${channels}ch.wav --endian little $OUT/sound-LEI24-${channels}ch.raw
    sox $OUT/sound-LEI32-${channels}ch.wav --endian little $OUT/sound-LEI32-${channels}ch.raw
    sox $OUT/sound-LEF32-${channels}ch.wav --endian little $OUT/sound-LEF32-${channels}ch.raw
    sox $OUT/sound-LEF64-${channels}ch.wav --endian little $OUT/sound-LEF64-${channels}ch.raw  

    # Big endian WAVE files
    sox $IN/sound.wav --endian big --encoding signed-integer --bits 16 --channels $channels $OUT/sound-BEI16-${channels}ch.wav
    sox $IN/sound.wav --endian big --encoding signed-integer --bits 24 --channels $channels $OUT/sound-BEI24-${channels}ch.wav
    sox $IN/sound.wav --endian big --encoding signed-integer --bits 32 --channels $channels $OUT/sound-BEI32-${channels}ch.wav
    sox $IN/sound.wav --endian big --encoding floating-point --bits 32 --channels $channels $OUT/sound-BEF32-${channels}ch.wav
    sox $IN/sound.wav --endian big --encoding floating-point --bits 64 --channels $channels $OUT/sound-BEF64-${channels}ch.wav
    
    # Big endian RAW files
    sox $OUT/sound-BEI16-${channels}ch.wav --endian big $OUT/sound-BEI16-${channels}ch.raw
    sox $OUT/sound-BEI24-${channels}ch.wav --endian big $OUT/sound-BEI24-${channels}ch.raw
    sox $OUT/sound-BEI32-${channels}ch.wav --endian big $OUT/sound-BEI32-${channels}ch.raw
    sox $OUT/sound-BEF32-${channels}ch.wav --endian big $OUT/sound-BEF32-${channels}ch.raw
    sox $OUT/sound-BEF64-${channels}ch.wav --endian big $OUT/sound-BEF64-${channels}ch.raw

done

echo ${0##*/}: Done.
