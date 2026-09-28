"""Convert CMUdict ARPAbet pronunciations to IPA (US style, like the books).

CMUdict: Copyright (C) 1993-2015 Carnegie Mellon University, BSD-style license
(see tools/LICENSES.md). Stress marks are placed before the syllable onset,
using a maximal-onset rule with a list of legal English onsets.
"""
VOWELS = {
    "AA": "ɑː", "AE": "æ", "AH": "ʌ", "AO": "ɔː", "AW": "aʊ", "AY": "aɪ",
    "EH": "e", "ER": "ɜːr", "EY": "eɪ", "IH": "ɪ", "IY": "iː", "OW": "oʊ",
    "OY": "ɔɪ", "UH": "ʊ", "UW": "uː",
}
UNSTRESSED = {"AH": "ə", "ER": "ər", "IY": "i", "UW": "u"}
CONS = {
    "B": "b", "CH": "tʃ", "D": "d", "DH": "ð", "F": "f", "G": "ɡ", "HH": "h",
    "JH": "dʒ", "K": "k", "L": "l", "M": "m", "N": "n", "NG": "ŋ", "P": "p",
    "R": "r", "S": "s", "SH": "ʃ", "T": "t", "TH": "θ", "V": "v", "W": "w",
    "Y": "j", "Z": "z", "ZH": "ʒ",
}
ONSETS = {
    ("P", "R"), ("B", "R"), ("T", "R"), ("D", "R"), ("K", "R"), ("G", "R"),
    ("F", "R"), ("TH", "R"), ("SH", "R"), ("P", "L"), ("B", "L"), ("K", "L"),
    ("G", "L"), ("F", "L"), ("S", "L"), ("S", "P"), ("S", "T"), ("S", "K"),
    ("S", "M"), ("S", "N"), ("S", "W"), ("T", "W"), ("D", "W"), ("K", "W"),
    ("S", "P", "R"), ("S", "T", "R"), ("S", "K", "R"), ("S", "P", "L"),
    ("S", "K", "W"), ("P", "Y"), ("B", "Y"), ("F", "Y"), ("M", "Y"), ("K", "Y"),
    ("HH", "Y"), ("V", "Y"),
}


def _is_vowel(ph):
    return ph[-1].isdigit()


def arpabet_to_ipa(phones):
    # "ER0" before a vowel: the r starts the next syllable (direction -> dəˈrekʃən)
    fixed = []
    for i, p in enumerate(phones):
        if p == "ER0" and i + 1 < len(phones) and _is_vowel(phones[i + 1]):
            fixed.extend(["AH0", "R"])
        else:
            fixed.append(p)
    phones = fixed
    nuclei = [i for i, p in enumerate(phones) if _is_vowel(p)]
    if not nuclei:
        return "".join(CONS.get(p, "") for p in phones)
    # syllable start index for each nucleus
    starts = [0]
    for a, b in zip(nuclei, nuclei[1:]):
        cluster = phones[a + 1:b]
        onset_len = 0
        for k in range(len(cluster), 0, -1):
            cand = tuple(cluster[len(cluster) - k:])
            if k == 1 or cand in ONSETS:
                if k == 1 and cand[0] == "NG":
                    continue
                onset_len = k
                break
        starts.append(b - onset_len)
    out = []
    for i, p in enumerate(phones):
        if i in starts and len(nuclei) > 1:
            nuc = nuclei[starts.index(i)]
            stress = phones[nuc][-1]
            if stress == "1":
                out.append("ˈ")
            elif stress == "2":
                out.append("ˌ")
        if _is_vowel(p):
            base, stress = p[:-1], p[-1]
            if stress == "0" and base in UNSTRESSED:
                out.append(UNSTRESSED[base])
            else:
                out.append(VOWELS[base])
        else:
            out.append(CONS[p])
    return "".join(out)


if __name__ == "__main__":
    import cmudict
    d = cmudict.dict()
    for w in ["negotiate", "agreement", "reimbursement", "confidentiality", "strategic", "company", "apply"]:
        print(w, "/" + arpabet_to_ipa(d[w][0]) + "/")
