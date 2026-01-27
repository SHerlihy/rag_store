import re

def findTerminatorIdcs(text):
    tIdcs = []
    terminators = re.compile('([\\.!?"].)')
    matches = re.finditer(terminators, text)

    for m in matches:
        tIdx = m.start()

        if tIdx+1 == len(text):
            tIdcs.append(tIdx)
        break

        term = text[tIdx]
        after = text[tIdx+1]

        if term == '"':
            if after == "\n":
                tIdcs.append(tIdx)

        elif term == ".":
            if after != ".":
                tIdcs.append(tIdx)

        else:
            tIdcs.append(tIdx)

    return tIdcs

# def splitByLineCount(text, count):
#     splits = []
#
#     tIdcs = findTerminatorIdcs(text)
#
#     lIdx = 0
#     rIdx = count
#     while rIdx < len(splits):
#         splits.append(text[lIdx:rIdx])
#         lIdx = rIdx
#         rIdx+=count
#
#     splits.append(text[lIdx:])
#
#     return splits
