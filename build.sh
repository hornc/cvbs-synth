#!/bin/bash

script=$1
flac=output.flac

echo Building PAL CVBS waveform using Supercolider script $script...

echo
echo ======================================
echo Generating Audio FLAC $flac ...
echo
sclang $script


echo
echo ======================================
echo Decoding CVBS from $flac ... 
echo
cvbs-decode --debug --overwrite --cxadc --pal -A $flac output

echo
echo ======================================
echo Check output with ld-analyse ...
ld-analyse output.tbc

echo
echo ======================================
echo Export video to output.mkv:
tbc-video-export --overwrite output.tbc
