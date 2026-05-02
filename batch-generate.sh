#!/usr/bin/env bash
# =============================================================================
# batch-generate.sh
# Militant Foodie AI Content System — Batch Content Pipeline
#
# Reads dishes.csv and runs generate-content.sh for every row.
# Outputs one JSON file per dish into output/
#
# Usage:
#   chmod +x batch-generate.sh
#   ./batch-generate.sh                        # process all dishes in dishes.csv
#   ./batch-generate.sh --csv my-dishes.csv    # use a custom CSV file
#   ./batch-generate.sh --dry-run              # preview without running Claude
#   ./batch-generate.sh --limit 3             # process first 3 dishes only
#   ./batch-generate.sh --shoots              # auto-detect photo-library/ folders
#
# CSV format (dishes.csv):
#   dish,angle,mood,cta,season,photo
#   French Toast,warm against cold,seductive,substack,Summer,photo-library/french-toast/hero.jpg
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
CSV_FILE="dishes.csv"
DRY_RUN=false
LIMIT=0   # 0 = no limit
AUTO_SHOOTS=false
OUTPUT_DIR="./output"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE_SCRIPT="$REPO_ROOT/generate-content.sh"

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --csv)     CSV_FILE="$2";    shift 2 ;;
    --dry-run) DRY_RUN=true;     shift ;;
    --limit)   LIMIT="$2";       shift 2 ;;
    --shoots)  AUTO_SHOOTS=true; shift ;;
    --output)  OUTPUT_DIR="$2";  shift 2 ;;
    *) echo -e "${RED}Unknown option: $1${RESET}"; exit 1 ;;
  esac
done

# ── Validate ──────────────────────────────────────────────────────────────────
if [[ ! -f "$GENERATE_SCRIPT" ]]; then
  echo -e "${RED}Error: generate-content.sh not found at $GENERATE_SCRIPT${RESET}"
  echo "Make sure both scripts are in the same directory."
  exit 1
fi

if [[ ! -x "$GENERATE_SCRIPT" ]]; then
  echo -e "${YELLOW}Making generate-content.sh executable...${RESET}"
  chmod +x "$GENERATE_SCRIPT"
fi

mkdir -p "$OUTPUT_DIR"

# ── Helpers ───────────────────────────────────────────────────────────────────
log()     { echo -e "${CYAN}→${RESET}  $1"; }
success() { echo -e "${GREEN}✓${RESET}  $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $1"; }
fail()    { echo -e "${RED}✗${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${BLUE}$1${RESET}"; echo -e "${BLUE}$(printf '%.0s─' {1..60})${RESET}"; }

# ── Auto-detect photo-library/ folders ───────────────────────────────────────────────
# If --shoots flag is used, scan photo-library/ folder and build a temp CSV
if $AUTO_SHOOTS; then
  SHOOTS_DIR="$REPO_ROOT/shoots"
  if [[ ! -d "$SHOOTS_DIR" ]]; then
    echo -e "${RED}Error: photo-library/ directory not found.${RESET}"
    echo "Create a photo-library/ folder with subfolders per dish, each containing a photo."
    exit 1
  fi

  TEMP_CSV=$(mktemp /tmp/dishes_XXXXXX.csv)
  echo "dish,angle,mood,cta,season,photo" > "$TEMP_CSV"

  while IFS= read -r -d '' dir; do
    dish_slug=$(basename "$dir")
    dish_name=$(echo "$dish_slug" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

    # Find first image in the folder
    photo=$(find "$dir" -maxdepth 1 \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.heic" \) | head -1)
    photo="${photo:-}"

    # Default values for auto-detected dishes
    echo "\"$dish_name\",\"$dish_name dish\",seductive,substack,$(date +"%B"),\"$photo\"" >> "$TEMP_CSV"
    log "Auto-detected: $dish_name"
  done < <(find "$SHOOTS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  CSV_FILE="$TEMP_CSV"
  warn "Auto-detected dishes from photo-library/. Review the CSV before running without --dry-run."
fi

# ── Validate CSV ──────────────────────────────────────────────────────────────
if [[ ! -f "$CSV_FILE" ]]; then
  echo -e "${RED}Error: CSV file not found: $CSV_FILE${RESET}"
  echo ""
  echo "Create a dishes.csv file with this format:"
  echo "  dish,angle,mood,cta,season,photo"
  echo "  French Toast,warm against cold,seductive,substack,Summer,photo-library/french-toast/hero.jpg"
  exit 1
fi

# Count rows (excluding header)
TOTAL_DISHES=$(tail -n +2 "$CSV_FILE" | grep -c '[^[:space:]]' || true)

if [[ $TOTAL_DISHES -eq 0 ]]; then
  echo -e "${RED}Error: No dishes found in $CSV_FILE${RESET}"
  exit 1
fi

# Apply limit
if [[ $LIMIT -gt 0 && $LIMIT -lt $TOTAL_DISHES ]]; then
  PROCESS_COUNT=$LIMIT
else
  PROCESS_COUNT=$TOTAL_DISHES
fi

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${BLUE}  Militant Foodie — Batch Content Pipeline${RESET}"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "  CSV:       $CSV_FILE"
echo -e "  Dishes:    $TOTAL_DISHES found, $PROCESS_COUNT to process"
echo -e "  Output:    $OUTPUT_DIR"
echo -e "  Dry run:   $DRY_RUN"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"

# ── Preview dishes ────────────────────────────────────────────────────────────
header "📋  Dishes to process"
ROW=0
while IFS=',' read -r dish angle mood cta season photo; do
  # Skip header
  [[ "$dish" == "dish" ]] && continue
  ((ROW++))
  [[ $LIMIT -gt 0 && $ROW -gt $LIMIT ]] && break

  # Strip quotes
  dish="${dish//\"/}"
  photo="${photo//\"/}"

  photo_status=""
  if [[ -n "$photo" && -f "$photo" ]]; then
    photo_status="${GREEN}📷 photo found${RESET}"
  elif [[ -n "$photo" ]]; then
    photo_status="${YELLOW}⚠ photo not found${RESET}"
  else
    photo_status="${CYAN}no photo${RESET}"
  fi

  echo -e "  ${BOLD}[$ROW]${RESET} $dish — $photo_status"
done < "$CSV_FILE"

echo ""
if $DRY_RUN; then
  warn "DRY RUN mode — prompts will print but Claude will not be called."
else
  echo -e "${BOLD}Starting pipeline in 3 seconds... (Ctrl+C to cancel)${RESET}"
  sleep 3
fi

# ── Process each dish ─────────────────────────────────────────────────────────
SUCCEEDED=0
FAILED=0
FAILED_DISHES=()
ROW=0

while IFS=',' read -r dish angle mood cta season photo; do
  # Skip header
  [[ "$dish" == "dish" ]] && continue
  ((ROW++))
  [[ $LIMIT -gt 0 && $ROW -gt $LIMIT ]] && break

  # Strip quotes
  dish="${dish//\"/}"
  angle="${angle//\"/}"
  mood="${mood//\"/}"
  cta="${cta//\"/}"
  season="${season//\"/}"
  photo="${photo//\"/}"

  header "🍽  [$ROW/$PROCESS_COUNT] $dish"

  # Build command
  CMD="$GENERATE_SCRIPT"
  CMD+=" --dish \"$dish\""
  CMD+=" --angle \"$angle\""
  CMD+=" --mood \"${mood:-seductive}\""
  CMD+=" --cta \"${cta:-substack}\""
  CMD+=" --season \"${season:-$(date +"%B")}\""
  CMD+=" --output \"$OUTPUT_DIR\""

  if [[ -n "$photo" && -f "$photo" ]]; then
    CMD+=" --photo \"$photo\""
    log "Photo: $photo"
  elif [[ -n "$photo" ]]; then
    warn "Photo not found: $photo — skipping photo attachment"
  fi

  if $DRY_RUN; then
    CMD+=" --dry-run"
  fi

  log "Running: $CMD"
  echo ""

  # Execute and track result
  if eval "$CMD"; then
    ((SUCCEEDED++))
    success "[$ROW/$PROCESS_COUNT] $dish — complete"
  else
    ((FAILED++))
    FAILED_DISHES+=("$dish")
    fail "[$ROW/$PROCESS_COUNT] $dish — failed"
  fi

  # Brief pause between dishes to avoid rate limiting
  if [[ $ROW -lt $PROCESS_COUNT ]]; then
    log "Pausing 5s before next dish..."
    sleep 5
  fi

done < "$CSV_FILE"

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}  Batch Complete${RESET}"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "  Processed:  $PROCESS_COUNT dishes"
echo -e "  ${GREEN}Succeeded:${RESET}  $SUCCEEDED"
echo -e "  ${RED}Failed:${RESET}     $FAILED"
echo -e "  Output:     $OUTPUT_DIR/"
echo ""

if [[ ${#FAILED_DISHES[@]} -gt 0 ]]; then
  echo -e "${RED}Failed dishes:${RESET}"
  for d in "${FAILED_DISHES[@]}"; do
    echo -e "  ${RED}✗${RESET}  $d"
  done
  echo ""
fi

# List output files
echo -e "${BOLD}Output files:${RESET}"
find "$OUTPUT_DIR" -name "*.json" -newer "$CSV_FILE" 2>/dev/null | sort | while read -r f; do
  size=$(wc -c < "$f")
  echo -e "  ${GREEN}✓${RESET}  $(basename "$f") (${size} bytes)"
done

echo -e "\n${BOLD}Next steps:${RESET}"
echo -e "  1. Review JSON files in $OUTPUT_DIR/"
echo -e "  2. Pick your caption versions"
echo -e "  3. Import to Later / Buffer for scheduling"
echo -e "  4. Set posting times: 11am–1pm or 6–8pm weekdays\n"

# Cleanup temp CSV if auto-shoots mode
if $AUTO_SHOOTS && [[ -f "${TEMP_CSV:-}" ]]; then
  rm -f "$TEMP_CSV"
fi

exit $( [[ $FAILED -eq 0 ]] && echo 0 || echo 1 )
