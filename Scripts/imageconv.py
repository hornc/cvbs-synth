#!/usr/bin/env python3
import sys
import PIL.Image
import os 

dir_path = os.path.dirname(os.path.realpath(__file__)) 

Y_OFFSET = 0 # 76  # was 276
MAX_Y = 520
MAX_X = 530  # max 834
FRAME_SIZE = 625 * MAX_X  # 'pixels' in frame to covert to proportions summing to 1

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
        for l in [self.bright, self.length]:
            print("CHECK:", len(l))
        assert len(self.bright) == len(self.length)
        #assert len(self.bright) % 2 == 0

    def pad(self):
        # pads durations to sum to 1
        tot = sum(self.length)
        self.length.append(1 - tot)
        self.bright.append(0)

    def split(self, n=2):
        # split hImage into n hImages
        # TODO: remove this if it ends up unused...
        r = [hImage() for i in range(n)]
        d = len(self.x) // n
        for i in range(n):
            r[i].bright = self.bright[i*d:(i+1)*d]
            r[i].length = self.length[i*d:(i+1)*d]
        return r

    def output(self):
        self.pad()
        sc_durs = [f"{x:.18f}" for x in self.length]
        r = f"""
var amps = {self.bright};
var durs = [{', '.join(sc_durs)}];
"""
        return r


def output_hline(lines):
    frame = hImage()
    for i, line in enumerate(lines):
        if i < Y_OFFSET:
            continue
        if i & 1:  # skip odd numbered lines (to avoid interlace issues)
            continue
        needs_len = False
        for segment in line:
            br = segment[0] / 4  # scale bright levels to 0.0-1.0
            if needs_len:
                len_ = segment[1] - frame.x[-1]
                frame.length.append(len_ / FRAME_SIZE)
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
            frame.length.append(len_ / FRAME_SIZE)

    frame.check()
    return frame.output()


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

        # lines gets populated with list of [x start pos, greyscale bright level]s
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
    print(f'DEBUG lines: {len(lines)}')
    print('Lines:', lines)
    output = output_hline(lines)
    print(output)
    with open(TEMPLATE, 'r') as f:
        scd = f.read().replace(REPLACE, output)

    print(f'Writing to file: {OUTFILE}...')
    with open(OUTFILE, 'w') as out:
        out.write(scd)


if __name__ == '__main__':
    main()
