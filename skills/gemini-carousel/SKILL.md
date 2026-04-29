# Skill: Gemini Carousel

> Generate a fully structured carousel brief that Claude hands off to Gemini for visual production.

---

## How Claude Uses This Skill

Claude's job is to write the complete creative brief and slide-by-slide copy for a carousel — then produce a formatted prompt for Gemini to generate the visuals. Claude handles all the words, structure, and creative direction. Gemini handles the image generation.

---

## Instructions

1. **Get the brief:** dish or topic, mood/aesthetic, number of slides (default: 7), and any specific visual references Mike has in mind.
2. **Structure the carousel:**
   - **Slide 1:** Cover — bold hook, single image concept, no clutter
   - **Slides 2–6:** Content slides — one idea per slide, short copy (max 15 words), clear visual concept per slide
   - **Slide 7:** CTA slide — "Drop a comment for the recipe" or "Full recipe on Substack"
3. **Write slide copy in Mike's voice** — punchy, sensory, confident.
4. **Write a visual direction note for each slide** — lighting, composition, subject, mood. Mike shoots moody, dark-background food photography.
5. **Produce a Gemini image prompt** for each slide at the end.

---

## Output Format

### Slide [N]
**Copy:** [text that appears on the slide]
**Visual:** [what the image should show — composition, lighting, mood]
**Gemini prompt:** [ready-to-paste image generation prompt]

---

## Gemini Prompt Style

Each Gemini prompt should follow this structure:
> *"[Subject], [composition], [lighting style], moody food photography, dark background, cinematic, editorial, shot on 35mm, no text"*

---

## Example Prompt

> *"Build me a carousel for [dish]. Moody aesthetic, [N] slides. Hook is: [hook line]. Give me slide copy, visual direction, and a Gemini image prompt for each slide."*
