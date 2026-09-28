#!/usr/bin/env python3
"""Write the small PUBLIC sample dataset and the generic WordNet glosses.

Everything here is hand-written for this app (no book content), so the output
is committed and used by tests and as the fallback when private-data/ is empty.
  src/data/sample/dataset.json   hand-written sample (IPA from CMUdict)
  src/data/generic-glosses.json  WordNet 3.0 glosses for words in public texts
Usage: python3 tools/build_sample.py   (needs pip cmudict + nltk wordnet data)
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from build_dataset import ipa_for, wn  # noqa: E402

TOPICS = [
    {"code": "S1", "book": "sample", "en": "Office Basics", "vi": "Văn phòng cơ bản"},
    {"code": "S2", "book": "sample", "en": "Travel Basics", "vi": "Du lịch cơ bản"},
]
# (headword, topic, band850, tip, [ (word, pos, definition, example, vi) ], [ (phrase, vi, example) ])
FAMILIES = [
    ("company", "S1", False, "Plural: companies (y -> ies).", [
        ("company", "n", "a business that makes or sells things or services", "My sister works for a small software company.", "công ty"),
    ], [
        ("run a company", "điều hành công ty", "She has run the company for ten years."),
        ("join a company", "vào làm ở một công ty", "He joined the company after university."),
    ]),
    ("meet", "S1", False, "Past: met. Noun: meeting.", [
        ("meet", "v", "to come together with someone at a place and time", "Let's meet in the lobby at nine.", "gặp"),
        ("meeting", "n", "an event where people come together to talk", "The meeting will start in five minutes.", "cuộc họp"),
    ], [
        ("hold a meeting", "tổ chức cuộc họp", "We hold a team meeting every Monday."),
        ("meet a deadline", "kịp hạn chót", "Everyone worked late to meet the deadline."),
    ]),
    ("manage", "S1", False, "manager = person; management = the activity or the group of managers.", [
        ("manage", "v", "to be in charge of people or work", "He manages the sales team.", "quản lý"),
        ("manager", "n", "a person who is in charge of a team or business", "Please ask the manager for help.", "người quản lý"),
        ("management", "n", "the control of a business, or the people who control it", "The management decided to open a new shop.", "ban quản lý; việc quản lý"),
    ], [
        ("manage a team", "quản lý một nhóm", "It is not easy to manage a team of twenty."),
        ("senior management", "ban lãnh đạo cấp cao", "Senior management approved the plan."),
    ]),
    ("run", "S1", False, "Irregular: run - ran - run.", [
        ("run", "v", "to move fast on foot; to control or operate a business or machine", "They run a small café near the station.", "chạy; điều hành"),
    ], [
        ("run a business", "điều hành doanh nghiệp", "My parents run a family business."),
        ("run out of", "hết, cạn", "We ran out of paper this morning."),
    ]),
    ("report", "S1", False, None, [
        ("report", "n/v", "(n) a written or spoken description of facts; (v) to tell people about something", "I will finish the report by Friday.", "báo cáo"),
        ("reporter", "n", "a person who collects and writes news", "A reporter asked the director some questions.", "phóng viên"),
    ], [
        ("write a report", "viết báo cáo", "Can you write a report on the survey results?"),
    ]),
    ("book", "S2", False, "As a verb, book = reserve (đặt trước).", [
        ("book", "v/n", "(v) to arrange to have a seat, room or ticket; (n) a set of printed pages", "I booked a hotel room for two nights.", "đặt (chỗ); quyển sách"),
        ("booking", "n", "an arrangement to have a room, seat or ticket", "Your booking number is on the email.", "sự đặt chỗ"),
    ], [
        ("book a flight", "đặt vé máy bay", "We booked a flight to Da Nang."),
        ("fully booked", "kín chỗ", "The hotel is fully booked this weekend."),
    ]),
    ("travel", "S2", False, None, [
        ("travel", "v/n", "(v) to go from one place to another; (n) the activity of traveling", "She travels to Singapore twice a year.", "đi lại, du lịch"),
        ("traveler", "n", "a person who is on a trip", "The airport was full of travelers.", "du khách, người đi đường"),
    ], [
        ("business travel", "công tác", "Business travel costs rose this year."),
    ]),
    ("delay", "S2", False, None, [
        ("delay", "n/v", "(n) a time when something happens later than planned; (v) to make something late", "The storm delayed our flight by two hours.", "sự chậm trễ; trì hoãn"),
        ("delayed", "adj", "later than planned", "The delayed train finally arrived.", "bị trễ"),
    ], [
        ("without delay", "ngay lập tức", "Please reply without delay."),
    ]),
    ("ticket", "S2", False, None, [
        ("ticket", "n", "a piece of paper or digital record that lets you travel or enter an event", "Show your ticket at the gate.", "vé"),
    ], [
        ("buy a ticket", "mua vé", "You can buy a ticket online."),
    ]),
]
PASSAGES = [
    {"id": "sp1", "topic": "S1", "title": "A Busy Monday",
     "text": "Ms. Lan manages a small travel company. Every Monday, she holds a meeting with her team. Last week, the manager asked everyone to finish their reports before the meeting. Two employees ran out of time, so the meeting was delayed by an hour. Now the company's staff don't wait until Monday morning to write their reports.",
     "questions": [
         {"question": "What does Ms. Lan do every Monday?", "options": ["She travels abroad", "She holds a meeting", "She writes a book", "She buys tickets"], "answer": 1},
         {"question": "Why was the meeting delayed?", "options": ["The room was booked", "The manager was sick", "Some employees ran out of time", "The train was late"], "answer": 2},
     ]},
    {"id": "sp2", "topic": "S2", "title": "A Late Flight",
     "text": "Minh booked a flight to Hanoi for a business meeting. At the airport, he learned that his flight was delayed because of bad weather. He called the company's travel desk, and they booked him a ticket on an earlier train. Minh met his clients on time and said the trip was a good lesson for every traveler.",
     "questions": [
         {"question": "Why was the flight delayed?", "options": ["Bad weather", "A late pilot", "A booking error", "A strike"], "answer": 0},
         {"question": "How did Minh travel in the end?", "options": ["By bus", "By car", "By train", "By plane"], "answer": 2},
     ]},
]


def build_sample():
    words, families, collocations = [], [], []
    for fi, (head, topic, band, tip, forms, cols) in enumerate(FAMILIES, 1):
        fid = f"sf{fi}"
        members = []
        for word, pos, definition, example, vi in forms:
            wid = f"sw{len(words) + 1}"
            ipa = ipa_for(word)
            words.append({"id": wid, "word": word, "lemma": word, "pos": pos, "ipa": ipa,
                          "ipaSource": "cmudict" if ipa else None, "definition": definition, "example": example,
                          "vi": vi, "note": None, "topic": topic, "book": "sample", "family": fid,
                          "families": [fid], "isHead": word == head})
            members.append(wid)
        for phrase, vi, example in cols:
            collocations.append({"id": f"sc{len(collocations) + 1}", "family": fid, "phrase": phrase, "vi": vi, "example": example})
        families.append({"id": fid, "headword": head, "topic": topic, "book": "sample", "band850": band,
                         "members": members, "tip": tip, "page": None})
    return {"version": 1, "source": "sample", "topics": TOPICS, "families": families, "words": words,
            "collocations": collocations, "passages": PASSAGES, "glosses": {}}


def generic_glosses(texts, known, stop):
    out = {}
    if wn is None:
        return out
    for t in texts:
        for tok in re.findall(r"[A-Za-z]+", t):
            low = tok.lower()
            base = wn.morphy(low) or low
            if low in stop or base in known or base in out or low in known:
                continue
            syns = wn.synsets(base)
            if not syns:
                continue
            s = max(syns, key=lambda syn: sum(l.count() for l in syn.lemmas() if l.name().lower() == base))
            out[base] = {"pos": {"n": "n", "v": "v", "a": "adj", "s": "adj", "r": "adv"}[s.pos()], "definition": s.definition()}
    return dict(sorted(out.items()))


def main():
    ds = build_sample()
    os.makedirs(os.path.join(APP, "src", "data", "sample"), exist_ok=True)
    with open(os.path.join(APP, "src", "data", "sample", "dataset.json"), "w", encoding="utf-8") as fh:
        json.dump(ds, fh, ensure_ascii=False, indent=1)
    stop = set(json.load(open(os.path.join(APP, "src", "content", "function-words.json"), encoding="utf-8")))
    texts = []
    for w in ds["words"]:
        texts += [w["example"], w["definition"]]
    texts += [c["example"] for c in ds["collocations"]]
    for p in ds["passages"]:
        texts.append(p["text"])
        for q in p["questions"]:
            texts += [q["question"]] + q["options"]
    for d in json.load(open(os.path.join(APP, "src", "content", "dialogs.json"), encoding="utf-8")):
        texts += [d["title"], d["setting"]] + [l["text"] for l in d["lines"]]
    known = {w["word"] for w in ds["words"]}
    g = generic_glosses(texts, known, stop)
    with open(os.path.join(APP, "src", "data", "generic-glosses.json"), "w", encoding="utf-8") as fh:
        json.dump(g, fh, ensure_ascii=False, indent=0)
    print(f"sample words={len(ds['words'])} families={len(ds['families'])} glosses={len(g)}")


if __name__ == "__main__":
    main()
