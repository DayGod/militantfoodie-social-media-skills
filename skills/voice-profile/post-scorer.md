# Skill: Post Scorer

> Score any caption draft against Mike's voice and Instagram performance criteria — with specific notes to improve it.

---

## How Claude Uses This Skill

Before a post goes out, Claude runs it through a scoring rubric. The score is less important than the notes — the goal is to identify exactly what to fix before publishing. Claude scores ruthlessly but constructively.

---

## Scoring Rubric

Score each category 1–10. Total out of 50.

| Category | What to evaluate |
|---|---|
| **Hook strength** | Does line 1 stop the scroll? Is it specific, not generic? Does it work before the fold? |
| **Voice match** | Does it sound like Mike — sensory, confident, occasionally funny? Or does it sound like a food blogger? |
| **Story quality** | Is there a real story, memory, or angle? Or is it just describing the dish? |
| **CTA effectiveness** | Is there exactly one CTA? Is it the right one for this post? Does it land naturally? |
| **Formatting** | Is the spacing correct? Does the hook survive truncation? Are hashtags handled right? |

---

## Instructions

1. **Read the full caption.**
2. **Score each category 1–10** with a one-line rationale.
3. **Write 2–3 specific improvement notes** — not vague feedback, actionable rewrites.
4. **Flag any Voice Profile violations** from Section 7 (what Mike never sounds like).
5. **Give an overall verdict:** Post it / Needs work / Rewrite.
6. **Optionally:** rewrite the weakest section if score is below 35/50.

---

## Output Format

**Hook strength:** [score]/10 — [rationale]
**Voice match:** [score]/10 — [rationale]
**Story quality:** [score]/10 — [rationale]
**CTA effectiveness:** [score]/10 — [rationale]
**Formatting:** [score]/10 — [rationale]

**Total:** [score]/50

**Improvement notes:**
1. [specific note]
2. [specific note]
3. [specific note]

**Verdict:** Post it / Needs work / Rewrite

---

## Score Interpretation

| Score | Verdict |
|---|---|
| 45–50 | Post it — this is strong |
| 35–44 | Needs work — fix the flagged items |
| 25–34 | Significant rewrite needed |
| Below 25 | Start over with the Hook Generator |

---

## Example Prompt

> *"Score this caption: [paste caption]. Be specific about what's weak and what to fix. Rewrite the hook if it's under 6/10."*
