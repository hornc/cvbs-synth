#!/bin/bash
if [ "$#" -lt 1 ]; then
    echo "CVBS synth build process:"
    echo "  1. Use sclang NRT synthesis to generate a .flac"
    echo "  2. Decode CVBS from the .flac using cvbs-decode"
    echo "  3. Check CVBS output with ld-analyse"
    echo "  4. Export video to .mkv with tbc-video-export"
    echo "Usage: $0 <path to .scd file>"
    exit 1
fi

SC_EXT_PATH=$(sclang -l /dev/null <<EOF | grep "^/.*Extensions$" | head -n 1
Platform.userExtensionDir.postln;
0.exit;
EOF
)

script=$1

# likely flakey:
flac=$(grep outputFilePath $1 | grep -o "\w*\.flac")  # e.g. output.flac

echo Copying CVBS extension to $SC_EXT_PATH ...
cp Extensions/CVBS.sc $SC_EXT_PATH/CVBS/.
echo Building PAL CVBS waveform using Supercolider script $script...

echo
echo ======================================
echo Generating Audio FLAC $flac ...
echo
rm $flac
sclang $script

echo
echo ======================================
echo Decoding CVBS from $flac ... 
echo
rm output.tbc
cvbs-decode --debug --overwrite --cxadc --pal -A $flac output

echo
echo ======================================
echo Check output with ld-analyse ...
ld-analyse output.tbc

echo
echo ======================================
echo Export video to output.mkv:
tbc-video-export --overwrite output.tbc
