# Third-party data used by the dataset tools

| Data | Used for | License | Where |
|---|---|---|---|
| CMU Pronouncing Dictionary (cmudict 1.1.3 on PyPI) | IPA for word forms that the book does not give IPA for (ARPAbet → IPA in `tools/ipa.py`) | BSD-style, "Copyright (C) 1993-2015 Carnegie Mellon University. All rights reserved." (file `cmudict/data/LICENSE` in the package) | https://github.com/cmusphinx/cmudict |
| WordNet 3.0 (via `nltk` data package `wordnet`) | 1) irregular forms `src/features/lookup/irregular.json` (verb.exc, noun.exc, adj.exc); 2) fallback glosses for words that are not in the dataset (`src/data/generic-glosses.json`, `private-data/dataset.json`) | WordNet 3.0 license (permissive, BSD-like): "WordNet 3.0 Copyright 2006 by Princeton University. All rights reserved." | License text read from the `LICENSE` file inside the nltk `wordnet` data package (wordnet.princeton.edu is blocked by the sandbox) |

Checked 2026-09-28 by reading the LICENSE files shipped with the packages.
Wiktionary / kaikki.org were not used (blocked in this environment).

## WordNet 3.0 license (full text)

Permission to use, copy, modify and distribute this software and database and
its documentation for any purpose and without fee or royalty is hereby granted,
provided that you agree to comply with the following copyright notice and
statements, including the disclaimer, and that the same appear on ALL copies of
the software, database and documentation, including modifications that you make
for internal use or for distribution.

WordNet 3.0 Copyright 2006 by Princeton University. All rights reserved.

THIS SOFTWARE AND DATABASE IS PROVIDED "AS IS" AND PRINCETON UNIVERSITY MAKES
NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. BY WAY OF EXAMPLE, BUT NOT
LIMITATION, PRINCETON UNIVERSITY MAKES NO REPRESENTATIONS OR WARRANTIES OF
MERCHANT-ABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE
LICENSED SOFTWARE, DATABASE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY
PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.

The name of Princeton University or Princeton may not be used in advertising or
publicity pertaining to distribution of the software and/or database. Title to
copyright in this software, database and any associated documentation shall at
all times remain with Princeton University and LICENSEE agrees to preserve same.

## CMUdict license (full text)

Copyright (C) 1993-2015 Carnegie Mellon University. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. The contents of this file
   are deemed to be source code.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY CARNEGIE MELLON UNIVERSITY "AS IS" AND ANY
EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL CARNEGIE MELLON UNIVERSITY NOR ITS EMPLOYEES BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
