import re

def findTerminatedIdcs(text):
    tIdcs = []
    terminators = re.compile('(?s:.)([\\.!?"])(?s:.)')
    matches = re.finditer(terminators, text)

    for m in matches:
        tIdx = m.start(1)
        print(tIdx)

        prev = text[tIdx-1]
        term = text[tIdx]
        after = text[tIdx+1]

        if term == '"':
            if after != "\n":
                continue

        if term == after or term == prev:
            continue

        if after == "\n":
            tIdx+=1

        tIdcs.append(tIdx+1)

    return tIdcs

def splitByLineCount(text, count):
    splits = []

    tIdcs = findTerminatedIdcs(text)

    splits.append(text[:tIdcs[0]])

    tIdxLeft = 0
    tIdxRight = count
    while tIdxRight < len(tIdcs):
        sIdxLeft = tIdcs[tIdxLeft]
        sIdxRight = tIdcs[tIdxRight]

        splits.append(text[sIdxLeft:sIdxRight])
        tIdxLeft = tIdxRight
        tIdxRight+=count

    finalTerminated = tIdcs[tIdxLeft]

    if finalTerminated < len(text):
        splits.append(text[finalTerminated:])

    return splits
