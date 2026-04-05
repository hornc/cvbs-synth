#!/usr/bin/env python3
import sys
import PIL.Image
import os 

dir_path = os.path.dirname(os.path.realpath(__file__)) 

Y_OFFSET = 276
#MAX_Y = 576
#MAX_Y = 116
MAX_Y = 316
MAX_X = 530  # max 834

MIN_LENGTH = 20

TEMPLATE = dir_path + "/cvbs_scd_template.txt"
REPLACE = "// REPLACE_HERE //"
OUTFILE = dir_path + "/../Examples/CharlotteMoorman1968_portrait.scd"


def output_hline(lines):
    x = []
    y = []
    bright = []
    lengths = []
    for i, line in enumerate(lines):
        if i < Y_OFFSET:
            continue
        if i & 1:
            continue
        needs_len = False
        for segment in line:
            br = segment[0] / 4
            if needs_len:
                len_ = segment[1] - x[-1]
                lengths.append(len_)
            if br == 0:
                needs_len = False
                continue
            y.append(i)
            x.append(segment[1])
            br += 0.25
            bright.append(br)
            needs_len = True
        if needs_len:  # close off the last segment in the line, if needed
            len_ = MAX_X - x[-1]
            if len_ > 10:
                len_ -= 5
            lengths.append(len_)

    for l in [x, y, bright, lengths]:
        print("CHECK:", len(l))

    output = f"""
                \\x, {x},
                \\y, {y},
                \\length, {lengths},
                \\brightness, {bright},
    """
    return output


def main():
    fname = sys.argv[1]
    img = PIL.Image.open(fname).convert('L')
    print("Image", fname, "size:", img.size)
    width, height = img.size
    pixels = img.load()

    # Iterate through each row (horizontal line)
    lines = []
    for y in range(min(height, Y_OFFSET + MAX_Y)):
        current_line = []

        for x in range(width):
            if x < width - MAX_X:
                continue
            if x > MAX_X:
                continue
            brightness = pixels[x, y]
            b = brightness // 64
            x = x - (width - MAX_X)

            if not current_line or b != current_line[-1][0]:
                current_line.append([b, x])
            #else:
                # Close the old segment and start a new one
            #    row_segments.append(current_segment)
            #    current_segment = [(brightness, x)]

        # Don't forget the last segment of the row
        lines.append(current_line)

    for line in lines:
        print(line)

    output = output_hline(lines)
    print(output)
    with open(TEMPLATE, 'r') as f:
        scd = f.read().replace(REPLACE, output)

    print(f'Writing to file: {OUTFILE}...')
    with open(OUTFILE, 'w') as out:
        out.write(scd)


if __name__ == '__main__':
    main()
