---
name: meeting-notes
description: Turns raw, messy meeting notes or transcripts into a clean summary with explicit Decisions and Action Items sections. Use this whenever the user pastes meeting notes, a transcript, or a recap and asks to summarize it, clean it up, extract action items, or figure out who owes what — even if they just paste the text without saying "use meeting-notes".
---

# Meeting Notes Summarizer

Turn raw meeting notes into a short, scannable summary that makes decisions and follow-up work impossible to miss.

## Why this matters

Raw notes bury the two things people actually need afterward — what was decided, and who owes what — inside a wall of chronological detail. The job here is not to shorten the text; it's to re-sort it by what matters.

## Output format

Always structure the summary with these sections, in this order. Omit a section only if it's genuinely empty (e.g., no decisions were made) — note that explicitly rather than deleting the heading silently.

```markdown
## Summary
2-4 sentences capturing the purpose of the meeting and the overall outcome.

## Decisions
- [Decision made] — brief context if needed
(If none: "No decisions were recorded.")

## Action Items
- [ ] Task — @Owner — Due: [date, or "not specified"]
(If none: "No action items were recorded.")

## Open Questions
Anything left unresolved or flagged for follow-up. Omit this section entirely if there's nothing open.
```

## How to extract each part

- **Decisions**: Look for language like "we agreed", "decided to", "going with", "approved", or a clear resolution to a debate in the notes. A decision is a conclusion, not a topic that was merely discussed.
- **Action items**: Look for explicit asks, "I'll do X", "can you...", "next steps", or tasks implied by a decision (e.g., a decision to switch tools implies someone needs to migrate). Always try to attach an owner — if the notes don't name one, write "Unassigned" rather than guessing. Same for due dates: use what's stated (including relative dates like "by Friday" — convert to an actual date if the meeting date is known, otherwise keep it as written) or mark "not specified".
- **Open questions**: Things raised but not resolved — don't force these into decisions or action items just to fill a section.

## Guidelines

- Keep the Summary section tight — it's an orientation, not a recap of everything below it.
- Preserve names and specifics (tool names, numbers, dates) exactly as given; don't paraphrase them into vagueness.
- If the notes are ambiguous about whether something was decided or just proposed, say so rather than picking a side silently (e.g., "Proposed but not confirmed: ...").
- If the input has multiple topics or agenda items, it's fine to group decisions/action items under sub-headings by topic when that makes the output clearer — but keep the same three top-level sections.
