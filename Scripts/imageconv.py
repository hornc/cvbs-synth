#!/usr/bin/env python3
import sys
import PIL.Image
import os 

dir_path = os.path.dirname(os.path.realpath(__file__)) 

Y_OFFSET = 76  # was 276
#MAX_Y = 576
#MAX_Y = 116
MAX_Y = 520
MAX_X = 530  # max 834

MIN_LENGTH = 20

TEMPLATE = dir_path + "/cvbs_scd_template.txt"
REPLACE = "// REPLACE_HERE //"
OUTFILE = dir_path + "/../Examples/CharlotteMoorman1968_portrait.scd"


class hImage:
    """
    An image frame made from (horizontal) line segments.
    """
    def __init__(self):
        self.x = []
        self.y = []
        self.bright = []
        self.length = []

    def check(self):
        for l in [self.x, self.y, self.bright, self.length]:
            print("CHECK:", len(l))
        assert len(self.x) == len(self.y) == len(self.bright) == len(self.length)

    def split(self, n=2):
        # split hImage into n hImages
        r = [hImage() for i in range(n)]
        d = len(self.x) // n
        for i in range(n):
            r[i].x = self.x[i*d:(i+1)*d]
            r[i].y = self.y[i*d:(i+1)*d]
            r[i].bright = self.bright[i*d:(i+1)*d]
            r[i].length = self.length[i*d:(i+1)*d]
        return r

    def output(self):
        r = f"""
        Pbind(
                \\instrument, "hLine",
                \\x, {self.x},
                \\y, {self.y},
                \\length, {self.length},
                \\brightness, {self.bright},
                \\dur, Pseq([2], 1)
        ),
    """
        return r


def output_hline(lines):
    frame = hImage()
    for i, line in enumerate(lines):
        if i < Y_OFFSET:
            continue
        if i & 1:
            continue
        needs_len = False
        for segment in line:
            br = segment[0] / 4
            if needs_len:
                len_ = segment[1] - frame.x[-1]
                frame.length.append(len_)
            if br == 0:
                needs_len = False
                continue
            br += 0.25
            frame.y.append(i)
            frame.x.append(segment[1])
            frame.bright.append(br)
            needs_len = True
        if needs_len:  # close off the last segment in the line, if needed
            len_ = MAX_X - frame.x[-1]
            if len_ > 10:
                len_ -= 5
            frame.length.append(len_)

    frame.check()
    r = frame.split(8)
    for f in r:
        print(f' Checking {f}...')
        f.check()
    return ''.join([f.output() for f in [r[0], r[2], r[4], r[5], r[-1]]])  # 195 * 5 = 975 < 1024 synth limit
    # TODO: develop a better instrument to follow the scan lines in one synth
    # current hLine approach is using one synth per _line segment of a consistent brightness_
    # which is extremely wasteful.


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

    output = output_hline(lines)
    print(output)
    with open(TEMPLATE, 'r') as f:
        scd = f.read().replace(REPLACE, output)

    print(f'Writing to file: {OUTFILE}...')
    with open(OUTFILE, 'w') as out:
        out.write(scd)


if __name__ == '__main__':
    main()
