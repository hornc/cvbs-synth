#!/usr/bin/env python3
from copy import deepcopy

SPACE = 25  # monospace width


def hLine(data):
    x, y, length = data
    output = rf"""     Pbind(  
                \instrument, "hLine",
                \x, {x},
                \y, {y},  // max: 576, only even rows
                \length, {length},
                \dur, Pseq([2], 1)
        )"""
    return output


def vBox(data):
    x, y, w, h = data
    output = rf"""     Pbind(  
                \instrument, "Box",
                \x, {x},
                \y, {y},
                \brightness, 1,
                \width, {w},
                \height, {h},
                \dur, Pseq([2], 1)
        )"""
    return output


font = {
    ' ': [[[]]*3, [[]]*4],
    '-': [[[0], [-10], [20]], [[]]*4],
    'H': [[[0], [-10], [20]], [[0, 20],[-20, -20],[2, 2],[20, 20]]],
    'E': [[[0,0,0], [0,-10,-20], [20,15,20]], [[0],[-20],[2],[20]]],
    'L': [[[0], [0], [20]], [[0],[-20],[2],[20]]],
    'O': [[[7,7], [0,-20], [10,10]], [[0, 20],[-18, -18],[2, 2],[15, 15]]],
    'W': [[[0], [0], [20]], [[0, 10, 20],[-20,-10,-20],[2,2,2],[20,10, 20]]],
    'R': [[[0], [-16], [18]], [[0],[-20],[2],[20]]],
    'D': [[[2,2], [0,-20], [10,10]], [[0, 20],[-18, -15],[2, 2],[15, 10]]],
    '!': [[[]]*3, [[10, 10],[-20, -2],[2, 2],[15, 2]]],
}

# Convert all Box drawing pixel coords into screen proportions... 
W = 720
H = 576
def screenConv(box):
    # x, y, w, h
    xpad = 21 
    xscale = 0.93
    ypad = 3
    if not len(box[0]):
        return box
    new = [[], [], [], []]
    for i, v in enumerate(box[0]):
        v += xpad
        new[0].append(v/W * xscale)
    for i, v in enumerate(box[1]):
        v += ypad
        new[1].append(v/H)
    for i, v in enumerate(box[2]):
        new[2].append(v/W)
    for i, v in enumerate(box[3]):
        new[3].append(v/H)
    return new


def getLetter(c, x=0, y=0):
    if c in font:
        h,v = deepcopy(font[c])
    else:
        h,v = deepcopy(font['-'])
    if h[0]:
       for i, value in enumerate(h[0]):
           h[0][i] += x
    if h[1]:
       for i, value in enumerate(h[1]):
           h[1][i] += y
    if v[0]:
       for i, value in enumerate(v[0]):
           v[0][i] += x
    if v[1]:
       for i, value in enumerate(v[1]):
           v[1][i] += y
    # convert all verticals into screen % ...
    v = screenConv(v)
    return [h, v]


def text(s: str, x: int, y: int):
    horizontal = [[], [], []]
    vertical = [[], [], [], []]
    for c in s:
        h, v = getLetter(c, x, y)
        for i, value in enumerate(h):
            horizontal[i] += value
        for i, value in enumerate(v):
            vertical[i] += value
        x += SPACE
    h = hLine(horizontal)
    v = vBox(vertical)
    print(f"// {s}")
    print(f"{h},\n{v}")


if __name__ == '__main__':
    s = "HELLO WORLD!"
    text(s, 100, 200)
