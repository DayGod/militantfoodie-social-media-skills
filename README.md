# Militant Foodie — AI Content System

A complete AI-powered content system for Instagram and Substack, built around a defined voice and a library of skills that Claude uses to write, plan, score, and distribute food content.

---

## How It Works

Every file in this repo is a **skill** — a set of instructions that tells Claude exactly how to perform a specific content task in Mike's voice. To activate a skill, paste its raw GitHub URL into any Claude session and say: *"Use this skill."*

The **Voice Profile** is the foundation. It should be included in every session.

---

## Quick Start

1. Start a Claude session
2. Paste the raw URL of `skills/voice-profile.md`
3. Say: *"This is my voice profile. Write in this voice."*
4. Paste the raw URL of whichever skill you need
5. Give Claude your brief

---

## Voice Profile

| File | What it does |
|---|---|
| [`skills/voice-profile.md`](skills/voice-profile.md) | Defines Mike's tone, personality, audience, storytelling themes, platform voice, and content rules. Include this in every session. |

**Raw URL:**
```
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/voice-profile.md
```

---

## Skills Library

### ✍️ Writing

| Skill | File | What it does |
|---|---|---|
| Post Writer | [`skills/post-writer.md`](skills/post-writer.md) | Writes full Instagram captions — hook, story, CTA — in Mike's voice. Outputs two versions: full story and punchy. |
| Hook Generator | [`skills/hook-generator.md`](skills/hook-generator.md) | Generates 5–10 scroll-stopping first lines across different hook styles for any post or reel. |
| Newsletter Voice | [`skills/newsletter-voice.md`](skills/newsletter-voice.md) | Writes full Substack newsletters — subject line, opener, body, recipe bridge, recipe, and sign-off. |
| Reel Scripting | [`skills/reel-scripting.md`](skills/reel-scripting.md) | Writes scene-by-scene reel scripts with shot descriptions, voiceover, text overlays, and audio direction. |
| Pinned Comment | [`skills/pinned-comment.md`](skills/pinned-comment.md) | Writes 3 pinned comment options per post — recipe tease, Substack bridge, or engagement starter. |

---

### 📐 Formatting & Quality

| Skill | File | What it does |
|---|---|---|
| Post Formatter | [`skills/post-formatter.md`](skills/post-formatter.md) | Formats caption drafts for Instagram — line breaks, spacing, CTA placement, hashtag strategy. |
| Post Scorer | [`skills/post-scorer.md`](skills/post-scorer.md) | Scores any caption across 5 criteria (hook, voice, story, CTA, formatting) with specific improvement notes. |

---

### 🗂️ Planning

| Skill | File | What it does |
|---|---|---|
| Content Matrix | [`skills/content-matrix.md`](skills/content-matrix.md) | Generates 30+ post ideas mapped by content type, platform, and hook — instantly. |
| Niche Research | [`skills/niche-research.md`](skills/niche-research.md) | Researches what's working in food content right now and filters trends through Mike's voice and niche. |
| Analytics Dashboard | [`skills/analytics-dashboard.md`](skills/analytics-dashboard.md) | Interprets Instagram and Substack performance data — identifies what to double down on and what to drop. |

---

### 🎨 Visuals

| Skill | File | What it does |
|---|---|---|
| Graphic Designer | [`skills/graphic-designer.md`](skills/graphic-designer.md) | Briefs any visual asset — IG post, carousel cover, story, reel thumbnail — with composition, lighting, palette, and mood direction. |
| Gemini Carousel | [`skills/gemini-carousel.md`](skills/gemini-carousel.md) | Writes slide-by-slide copy and visual direction for carousels, with ready-to-paste Gemini image prompts. |
| Gemini Infographic | [`skills/gemini-infographic.md`](skills/gemini-infographic.md) | Designs infographic copy and layout direction for techniques, tips, and comparisons, with Gemini image prompts. |

---

## Typical Workflows

### Write and publish an Instagram post
1. Load `voice-profile.md`
2. Load `hook-generator.md` → generate hooks for your dish
3. Load `post-writer.md` → write the full caption
4. Load `post-scorer.md` → score it and fix anything weak
5. Load `post-formatter.md` → format it for Instagram
6. Load `pinned-comment.md` → write the pinned comment

---

### Write a Substack newsletter
1. Load `voice-profile.md`
2. Load `newsletter-voice.md` → full draft with subject line and recipe
3. Load `post-writer.md` → write the IG teaser caption to drive traffic

---

### Plan a month of content
1. Load `voice-profile.md`
2. Load `niche-research.md` → find what's trending and fits Mike's niche
3. Load `content-matrix.md` → generate 30+ ideas with hooks
4. Load `post-writer.md` → start writing the best ones

---

### Build a carousel
1. Load `voice-profile.md`
2. Load `gemini-carousel.md` → full slide copy + Gemini image prompts
3. Load `post-writer.md` → write the caption to go with it

---

## Raw URLs — All Skills

Copy and paste these directly into Claude:

```
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/voice-profile.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/post-writer.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/hook-generator.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/newsletter-voice.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/reel-scripting.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/pinned-comment.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/post-formatter.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/post-scorer.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/content-matrix.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/niche-research.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/analytics-dashboard.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/graphic-designer.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/gemini-carousel.md
https://raw.githubusercontent.com/DayGod/militantfoodie-social-media-skills/main/skills/gemini-infographic.md
```

---

## Adding New Skills

1. Create a new `.md` file in the `skills/` folder
2. Follow the structure: Overview → Instructions → Output Format → Example Prompt
3. Update this README with the new skill
4. Add the raw URL to the list above

---

*Built for Militant Foodie · Powered by Claude*
