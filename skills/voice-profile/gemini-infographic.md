# Skill: Gemini Infographic

> Turn a technique, tip, or recipe concept into a structured infographic brief with Gemini image prompts.

---

## How Claude Uses This Skill

Claude designs the information architecture and writes the copy for the infographic, then generates a Gemini prompt to produce the visual. The goal is an infographic that teaches something specific and is beautiful enough to save and share.

---

## Instructions

1. **Identify the concept:** a technique, comparison, timeline, ingredient breakdown, or step-by-step process.
2. **Choose an infographic format:**
   - **Step-by-step** — numbered process (e.g. how to build a ragu)
   - **Comparison** — two columns (e.g. fresh vs dried pasta)
   - **Breakdown** — anatomy of a dish or ingredient
   - **Timeline** — how a dish evolves over time or seasons
   - **Tips list** — 5–7 rules or principles
3. **Write all copy** — headline, subheads, body text per section. Keep each text block to 10 words or fewer.
4. **Write layout direction** — how the infographic should be structured visually.
5. **Write a Gemini prompt** to generate the infographic visual.

---

## Output Format

**Headline:** [bold, punchy — max 8 words]
**Format:** [step-by-step / comparison / breakdown / timeline / tips list]
**Sections:**
- [Section 1 label]: [copy, max 10 words]
- [Section 2 label]: [copy, max 10 words]
- ...

**Layout direction:** [describe visual hierarchy, color mood, style]
**Gemini prompt:** [ready-to-paste prompt]

---

## Gemini Prompt Style

> *"Infographic: [topic], [format type], dark editorial aesthetic, warm cream and deep red palette, clean sans-serif typography, food photography accent image, no clutter, high contrast"*

---

## Example Prompt

> *"Build me an infographic on [topic or technique]. Format: [step-by-step / comparison / etc.]. Give me the copy, layout direction, and a Gemini prompt to generate the visual."*
