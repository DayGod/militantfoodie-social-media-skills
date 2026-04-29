# Skill: Analytics Dashboard

> Interpret Mike's Instagram and Substack performance data — tell him what to double down on and what to drop.

---

## How Claude Uses This Skill

Claude can't pull data directly from Instagram or Substack — Mike pastes or describes his numbers. Claude then interprets the data, identifies patterns, and gives direct recommendations on what's working and what's not. The output is a clear action plan, not a spreadsheet.

---

## Instructions

1. **Ask Mike to paste or describe his data.** Useful inputs include:
   - Instagram: reach, impressions, saves, shares, comments, follows per post (last 30–90 days)
   - Substack: open rate, click rate, subscriber growth, top performing issues
   - Any post that over- or under-performed he wants to understand
2. **Identify the key signals:**
   - **Saves** = content people find valuable (recipes, techniques, tips)
   - **Shares** = content that resonates emotionally or culturally
   - **Comments** = content that sparks conversation or creates desire
   - **Follows from a post** = content that converts new audiences
   - **Reach vs. impressions** = ratio indicates how often existing followers re-engage
3. **Look for patterns:**
   - Which content types outperform? (recipe reveals, carousels, reels, stories)
   - Which themes outperform? (nostalgia, seasonal, technique, opinion)
   - Which posting times outperform?
   - Which hooks generated the most engagement?
4. **Output three sections:**
   - **Double down on** — what's clearly working
   - **Test more of** — interesting signals, not enough data yet
   - **Stop or rethink** — low performance, not worth the production time
5. **Give 3–5 specific next post recommendations** based on the data.

---

## Output Format

### What's Working
[Pattern + specific evidence]

### Double Down On
- [Content type / theme / format]: [why, with data reference]

### Test More Of
- [Idea]: [hypothesis]

### Stop or Rethink
- [Content type / theme]: [why it's not earning its place]

### Next 5 Posts — Data-Backed Recommendations
1. [Post idea + why the data supports it]
2. ...

---

## Key Benchmarks (Instagram Food Content)

Use these as rough reference points — not gospel:

| Metric | Benchmark |
|---|---|
| Saves rate | 3–8% of reach = strong |
| Comments rate | 1–3% of reach = healthy |
| Shares rate | 0.5–2% of reach = good |
| Substack open rate | 40%+ = strong for food niche |
| Substack click rate | 5–10% = healthy |

---

## Example Prompt

> *"Here's my Instagram data for the last 30 days: [paste data or describe posts + metrics]. Tell me what's working, what to double down on, and give me 5 specific post recommendations based on the patterns."*
