#!/usr/bin/env bash
# =============================================================================
# generate-content.sh
# Militant Foodie AI Content System — Full Content Pipeline
#
# Runs every skill in sequence for a dish and outputs a complete JSON audit
# trail with all skill outputs in one file.
#
# Usage:
#   chmod +x generate-content.sh
#   ./generate-content.sh --dish "French Toast" --angle "indulgent, unexpected" --mood "seductive" --cta "substack"
#
# Options:
#   --dish      Dish name (required)
#   --angle     Story angle or inspiration (required)
#   --mood      Tone: nostalgic | punchy | seductive | funny | contemplative
#   --cta       CTA type: substack | comment | save
#   --photo     Path to photo file (optional)
#   --season    Season or month context (optional, defaults to current month)
#   --output    Output directory (optional, defaults to ./output)
#   --dry-run   Print prompts without calling Claude Code
# =============================================================================

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Defaults ──────────────────────────────────────────────────────────────────
DISH=""
ANGLE=""
MOOD="seductive"
CTA="substack"
PHOTO=""
SEASON=$(date +"%B")
OUTPUT_DIR="./output"
DRY_RUN=false
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --dish)    DISH="$2";      shift 2 ;;
    --angle)   ANGLE="$2";     shift 2 ;;
    --mood)    MOOD="$2";      shift 2 ;;
    --cta)     CTA="$2";       shift 2 ;;
    --photo)   PHOTO="$2";     shift 2 ;;
    --season)  SEASON="$2";    shift 2 ;;
    --output)  OUTPUT_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true;   shift ;;
    *) echo -e "${RED}Unknown option: $1${RESET}"; exit 1 ;;
  esac
done

# ── Validate required args ────────────────────────────────────────────────────
if [[ -z "$DISH" ]]; then
  echo -e "${RED}Error: --dish is required.${RESET}"
  echo "Usage: ./generate-content.sh --dish \"French Toast\" --angle \"indulgent, unexpected\""
  exit 1
fi

if [[ -z "$ANGLE" ]]; then
  echo -e "${YELLOW}No --angle provided. Defaulting to dish name as angle.${RESET}"
  ANGLE="$DISH"
fi

# ── Setup ─────────────────────────────────────────────────────────────────────
DISH_SLUG=$(echo "$DISH" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
OUTPUT_FILE="$OUTPUT_DIR/${DISH_SLUG}_${TIMESTAMP}.json"
mkdir -p "$OUTPUT_DIR"

# ── Helpers ───────────────────────────────────────────────────────────────────
log()     { echo -e "${CYAN}→${RESET}  $1"; }
success() { echo -e "${GREEN}✓${RESET}  $1"; }
step()    { echo -e "\n${BOLD}${BLUE}[$1/9]${RESET} ${BOLD}$2${RESET}"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $1"; }

# Run a claude prompt and return output
# In dry-run mode, prints the prompt instead
run_claude() {
  local skill="$1"
  local prompt="$2"

  if $DRY_RUN; then
    echo "--- DRY RUN: $skill ---"
    echo "$prompt"
    echo "--- END ---"
    echo "[dry-run output for $skill]"
    return
  fi

  # Check claude CLI is available
  if ! command -v claude &> /dev/null; then
    warn "claude CLI not found. Install Claude Code first: npm install -g @anthropic-ai/claude-code"
    echo "[claude not available]"
    return
  fi

  # Run claude with the skill context and prompt
  local skill_path="$SKILLS_DIR/$skill/SKILL.md"
  if [[ -f "$skill_path" ]]; then
    echo "$prompt" | claude --print \
      --system "$(cat "$REPO_ROOT/CLAUDE.md") $(cat "$skill_path")" \
      2>/dev/null || echo "[claude error for $skill]"
  else
    warn "Skill file not found: $skill_path"
    echo "$prompt" | claude --print 2>/dev/null || echo "[claude error]"
  fi
}

# Escape string for JSON
json_escape() {
  printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null \
    || printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n' | sed 's/\\n$//'
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${BLUE}  Militant Foodie — Content Pipeline${RESET}"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "  Dish:     $DISH"
echo -e "  Angle:    $ANGLE"
echo -e "  Mood:     $MOOD"
echo -e "  CTA:      $CTA"
echo -e "  Season:   $SEASON"
echo -e "  Photo:    ${PHOTO:-none}"
echo -e "  Output:   $OUTPUT_FILE"
echo -e "  Dry run:  $DRY_RUN"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}\n"

# ── Initialise JSON ───────────────────────────────────────────────────────────
cat > "$OUTPUT_FILE" << EOF
{
  "dish": "$DISH",
  "slug": "$DISH_SLUG",
  "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "inputs": {
    "angle": "$ANGLE",
    "mood": "$MOOD",
    "cta": "$CTA",
    "season": "$SEASON",
    "photo": "$PHOTO"
  },
  "outputs": {
EOF

# ── Step 1: Graphic Designer ──────────────────────────────────────────────────
step 1 "Graphic Designer — Visual Brief"
PROMPT_GRAPHIC="Brief a visual asset for '$DISH'. Dark and moody aesthetic. Single hero shot. The dish is: $ANGLE. Include a text overlay option and a Gemini image prompt."
log "Running graphic-designer skill..."
OUTPUT_GRAPHIC=$(run_claude "graphic-designer" "$PROMPT_GRAPHIC")
success "Visual brief complete"
echo "    \"graphic_designer\": $(json_escape "$OUTPUT_GRAPHIC")," >> "$OUTPUT_FILE"

# ── Step 2: Hook Generator ────────────────────────────────────────────────────
step 2 "Hook Generator — First Lines"
PROMPT_HOOKS="Give me 10 hooks for a post about '$DISH'. Story angle: $ANGLE. Mood: $MOOD. Mix styles — curiosity gap, sensory, bold statement, nostalgia, contradiction. No food blogger energy. No exclamation points."
log "Running hook-generator skill..."
OUTPUT_HOOKS=$(run_claude "hook-generator" "$PROMPT_HOOKS")
success "Hooks generated"
echo "    \"hook_generator\": $(json_escape "$OUTPUT_HOOKS")," >> "$OUTPUT_FILE"

# ── Step 3: Post Writer ───────────────────────────────────────────────────────
step 3 "Post Writer — Instagram Caption"
PROMPT_CAPTION="Write me an Instagram caption for '$DISH'. Story angle: $ANGLE. Mood: $MOOD. CTA: $CTA. Give me two versions — full story and punchy. Use the best hook from the hook generator output."
log "Running post-writer skill..."
OUTPUT_CAPTION=$(run_claude "post-writer" "$PROMPT_CAPTION")
success "Caption written"
echo "    \"post_writer\": $(json_escape "$OUTPUT_CAPTION")," >> "$OUTPUT_FILE"

# ── Step 4: Post Scorer ───────────────────────────────────────────────────────
step 4 "Post Scorer — Quality Check"
PROMPT_SCORE="Score the stronger of the two caption versions below. Be specific. Rewrite the hook if it scores under 6/10. Caption to score: $OUTPUT_CAPTION"
log "Running post-scorer skill..."
OUTPUT_SCORE=$(run_claude "post-scorer" "$PROMPT_SCORE")
success "Caption scored"
echo "    \"post_scorer\": $(json_escape "$OUTPUT_SCORE")," >> "$OUTPUT_FILE"

# ── Step 5: Post Formatter ────────────────────────────────────────────────────
step 5 "Post Formatter — Instagram Format"
PROMPT_FORMAT="Format the best caption version for Instagram. Apply correct line breaks, spacing, CTA placement, and add 8 hashtags using the hashtag bank. Caption: $OUTPUT_CAPTION"
log "Running post-formatter skill..."
OUTPUT_FORMAT=$(run_claude "post-formatter" "$PROMPT_FORMAT")
success "Caption formatted"
echo "    \"post_formatter\": $(json_escape "$OUTPUT_FORMAT")," >> "$OUTPUT_FILE"

# ── Step 6: Pinned Comment ────────────────────────────────────────────────────
step 6 "Pinned Comment — Three Options"
PROMPT_PINNED="Write 3 pinned comment options for the '$DISH' post. CTA used in caption was $CTA. One recipe tease, one Substack bridge, one engagement starter."
log "Running pinned-comment skill..."
OUTPUT_PINNED=$(run_claude "pinned-comment" "$PROMPT_PINNED")
success "Pinned comments written"
echo "    \"pinned_comment\": $(json_escape "$OUTPUT_PINNED")," >> "$OUTPUT_FILE"

# ── Step 7: Gemini Carousel ───────────────────────────────────────────────────
step 7 "Gemini Carousel — Slide Structure"
PROMPT_CAROUSEL="Build a 7-slide carousel for '$DISH'. Moody aesthetic. Story angle: $ANGLE. Use the best hook from the hook generator. Give me slide copy, visual direction, and a Gemini image prompt for each slide."
log "Running gemini-carousel skill..."
OUTPUT_CAROUSEL=$(run_claude "gemini-carousel" "$PROMPT_CAROUSEL")
success "Carousel built"
echo "    \"gemini_carousel\": $(json_escape "$OUTPUT_CAROUSEL")," >> "$OUTPUT_FILE"

# ── Step 8: Gemini Infographic ────────────────────────────────────────────────
step 8 "Gemini Infographic — Visual Explainer"
PROMPT_INFOGRAPHIC="Build an infographic for '$DISH'. Pick the most interesting technique or ingredient story from: $ANGLE. Choose the best format (step-by-step, breakdown, or tips list). Give me copy, layout direction, and a Gemini image prompt."
log "Running gemini-infographic skill..."
OUTPUT_INFOGRAPHIC=$(run_claude "gemini-infographic" "$PROMPT_INFOGRAPHIC")
success "Infographic built"
echo "    \"gemini_infographic\": $(json_escape "$OUTPUT_INFOGRAPHIC")," >> "$OUTPUT_FILE"

# ── Step 9: Reel Script ───────────────────────────────────────────────────────
step 9 "Reel Scripting — Video Script"
PROMPT_REEL="Script a 30-second reel for '$DISH'. Format: recipe process. Delivery: text overlay with music. Story angle: $ANGLE. Full scene breakdown, hook on first frame, CTA on last frame."
log "Running reel-scripting skill..."
OUTPUT_REEL=$(run_claude "reel-scripting" "$PROMPT_REEL")
success "Reel scripted"

# Close JSON (no trailing comma on last item)
echo "    \"reel_scripting\": $(json_escape "$OUTPUT_REEL")" >> "$OUTPUT_FILE"
cat >> "$OUTPUT_FILE" << EOF
  },
  "ready_to_post": {
    "caption": "See post_formatter output above",
    "pinned_comment": "See pinned_comment output above — pick one",
    "carousel_slides": "See gemini_carousel output above",
    "reel_script": "See reel_scripting output above"
  }
}
EOF

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}  ✓ Pipeline complete${RESET}"
echo -e "${BOLD}${GREEN}══════════════════════════════════════════════════════════════${RESET}"
echo -e "  Output:  $OUTPUT_FILE"
echo -e "  Skills:  9 / 9 complete"
echo -e ""
echo -e "  Next steps:"
echo -e "  1. Open $OUTPUT_FILE"
echo -e "  2. Pick your caption version from post_writer"
echo -e "  3. Copy the formatted version from post_formatter"
echo -e "  4. Pick a pinned comment from pinned_comment"
echo -e "  5. Post it\n"
