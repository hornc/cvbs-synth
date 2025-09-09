#!/bin/bash

script=pal.scd
flac=pal01.flac

echo Building PAL CVBS waveform using Supercolider script $script...

echo
echo ======================================
echo Generating Audio FLAC $flac ...
echo
sclang pal.scd


echo
echo ======================================
echo Decoding CVBS from $flac ... 
echo
cvbs-decode --debug --overwrite --cxadc --pal -A $flac pal01

echo
echo ======================================
echo Check output with ld-analyse ...
ld-analyse pal01.tbc

