
def terminatorIdcs(text):
    tIdcs = []
    terminators = re.compile('([\.!?"].)')
    matches = re.finditer(terminators, text)

    for match in matches:
        tIdx = m.start()

        if text[tIdx] != '"':
            tIdcs.append(tIdx)

        if text[tIdx+1] == "\n":
            tIdcs.append(tIdx)

    return tIdcs

def splitByLineCount(text, count):
    splits = []

    tIdcs = terminatorIdcs(text)

    lIdx = 0
    rIdx = count
    while rIdx < len(splits):
        splits.append(text[lIdx:rIdx])
        lIdx = rIdx
        rIdx+=count

    splits.aapend(text[lIdx:])

    return splits
