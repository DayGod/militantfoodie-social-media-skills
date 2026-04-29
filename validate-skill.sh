#!/usr/bin/env bash
# =============================================================================
# validate-skills.sh
# Militant Foodie AI Content System — Skill Validator
#
# Validates every .md file in the repo against the Agent Skills spec.
#
# Checks:
#   1. YAML frontmatter exists (--- block at top of file)
#   2. Required frontmatter fields: name, description, version, platform
#   3. Field: name matches the filename (without .md)
#   4. Field: description is between 50–300 characters
#   5. Field: version follows semver format (e.g. 1.0, 1.1, 1.0.1)
#   6. File size is between 500 bytes and 50KB
#   7. Required markdown sections exist (varies by file type)
#   8. No empty files
#   9. Standard folder structure is intact
#  10. Example Prompt section exists in skill files
#
# Usage:
#   chmod +x validate-skills.sh
#   ./validate-skills.sh               # validate all .md files
#   ./validate-skills.sh --fix-hints   # show what to add to fix each failure
#   ./validate-skills.sh --skills-only # validate skills/ folder only
#   ./validate-skills.sh --quiet       # only show failures and summary
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Flags ─────────────────────────────────────────────────────────────────────
FIX_HINTS=false
SKILLS_ONLY=false
QUIET=false

for arg in "$@"; do
  case $arg in
    --fix-hints)   FIX_HINTS=true ;;
    --skills-only) SKILLS_ONLY=true ;;
    --quiet)       QUIET=false ;;  # quiet mode placeholder — kept for future use
  esac
done

# ── Constants ─────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
MIN_FILE_BYTES=500
MAX_FILE_BYTES=51200   # 50KB
MIN_DESC_CHARS=50
MAX_DESC_CHARS=300

# Required frontmatter fields for all skill files
REQUIRED_FIELDS=("name" "description" "version" "platform")

# Required markdown sections for files inside skills/
REQUIRED_SKILL_SECTIONS=("## How Claude Uses This Skill" "## Instructions" "## Output Format" "## Example Prompt")

# Required root files
REQUIRED_ROOT_FILES=("README.md" "VERSION.md")

# Required folder structure
REQUIRED_DIRS=("skills")

# ── Counters ──────────────────────────────────────────────────────────────────
TOTAL=0
PASSED=0
FAILED=0
WARNINGS=0
declare -a FAILURE_SUMMARY=()
declare -a WARNING_SUMMARY=()

# ── Helpers ───────────────────────────────────────────────────────────────────
pass()    { echo -e "  ${GREEN}✓${RESET}  $1"; ((PASSED++)); }
fail()    { echo -e "  ${RED}✗${RESET}  $1"; ((FAILED++)); FAILURE_SUMMARY+=("$FILE_REL: $1"); }
warn()    { echo -e "  ${YELLOW}⚠${RESET}  $1"; ((WARNINGS++)); WARNING_SUMMARY+=("$FILE_REL: $1"); }
info()    { echo -e "  ${CYAN}→${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${BLUE}$1${RESET}"; echo -e "${BLUE}$(printf '%.0s─' {1..60})${RESET}"; }
subhead() { echo -e "\n${BOLD}$1${RESET}"; }

hint() {
  if $FIX_HINTS; then
    echo -e "  ${CYAN}    FIX:${RESET} $1"
  fi
}

# Extract a frontmatter field value from a file
# Usage: get_field "name" "/path/to/file.md"
get_field() {
  local field="$1"
  local file="$2"
  # Match "field: value" inside the first --- block
  awk '/^---/{found++; next} found==1 && /^'"$field"':/{print; exit}' "$file" \
    | sed "s/^$field:[[:space:]]*//" \
    | tr -d '"'\''`'
}

# Check if file has a YAML frontmatter block
has_frontmatter() {
  local file="$1"
  local first_line
  first_line=$(head -n 1 "$file")
  if [[ "$first_line" == "---" ]]; then
    # Check there's a closing ---
    tail -n +2 "$file" | grep -qm1 "^---$" && return 0
  fi
  return 1
}

# Check if a string is valid semver-ish (1.0 / 1.1 / 1.0.1)
valid_version() {
  echo "$1" | grep -qE '^[0-9]+\.[0-9]+(\.[0-9]+)?$'
}

# ── Structure Checks ──────────────────────────────────────────────────────────
check_structure() {
  header "📁  Repo Structure"

  # Required dirs
  for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$REPO_ROOT/$dir" ]]; then
      pass "Directory exists: $dir/"
    else
      FILE_REL="[structure]"
      fail "Missing required directory: $dir/"
      hint "Create the directory: mkdir $dir"
    fi
  done

  # Required root files
  for f in "${REQUIRED_ROOT_FILES[@]}"; do
    if [[ -f "$REPO_ROOT/$f" ]]; then
      pass "Root file exists: $f"
    else
      FILE_REL="[structure]"
      fail "Missing required root file: $f"
      hint "Create $f in the repo root"
    fi
  done

  # Warn about unexpected root .md files
  while IFS= read -r -d '' f; do
    fname=$(basename "$f")
    is_expected=false
    for expected in "${REQUIRED_ROOT_FILES[@]}"; do
      [[ "$fname" == "$expected" ]] && is_expected=true && break
    done
    if ! $is_expected; then
      FILE_REL="[structure]"
      warn "Unexpected .md file in root: $fname (expected only README.md and VERSION.md)"
    fi
  done < <(find "$REPO_ROOT" -maxdepth 1 -name "*.md" -print0)
}

# ── File Validator ────────────────────────────────────────────────────────────
validate_file() {
  local filepath="$1"
  local is_skill="$2"   # true if inside skills/
  FILE_REL="${filepath#$REPO_ROOT/}"
  local filename
  filename=$(basename "$filepath" .md)

  ((TOTAL++))
  subhead "📄  $FILE_REL"

  # ── Check 1: Not empty ──────────────────────────────────────────────────────
  if [[ ! -s "$filepath" ]]; then
    fail "File is empty"
    hint "Add content — at minimum, YAML frontmatter and a ## How Claude Uses This Skill section"
    return
  else
    pass "File is not empty"
  fi

  # ── Check 2: File size ──────────────────────────────────────────────────────
  local size
  size=$(wc -c < "$filepath")
  if (( size < MIN_FILE_BYTES )); then
    fail "File too small: ${size} bytes (minimum ${MIN_FILE_BYTES})"
    hint "Skill files should be at least 500 bytes — expand Instructions or Output Format sections"
  elif (( size > MAX_FILE_BYTES )); then
    fail "File too large: ${size} bytes (maximum ${MAX_FILE_BYTES})"
    hint "Consider splitting into multiple skill files"
  else
    pass "File size OK: ${size} bytes"
  fi

  # ── Check 3: YAML frontmatter exists ───────────────────────────────────────
  if ! has_frontmatter "$filepath"; then
    fail "Missing YAML frontmatter (file must start with ---)"
    hint "Add this block to the very top of the file:
---
name: $filename
description: \"A 1–2 sentence description of what this skill does (50–300 chars)\"
version: \"1.0\"
platform: \"instagram, substack\"
---"
    # Can't check fields without frontmatter — skip remaining field checks
    if $is_skill; then check_skill_sections "$filepath"; fi
    return
  else
    pass "YAML frontmatter found"
  fi

  # ── Check 4: Required frontmatter fields ────────────────────────────────────
  for field in "${REQUIRED_FIELDS[@]}"; do
    local value
    value=$(get_field "$field" "$filepath")
    if [[ -z "$value" ]]; then
      fail "Missing frontmatter field: $field"
      hint "Add '$field: ...' inside the --- block at the top of the file"
    else
      pass "Frontmatter field present: $field"

      # ── Check 5: name matches filename ──────────────────────────────────────
      if [[ "$field" == "name" ]]; then
        # Normalise: lowercase, replace spaces with hyphens
        local normalised
        normalised=$(echo "$value" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        if [[ "$normalised" != "$filename" ]]; then
          fail "name mismatch: frontmatter name '${value}' (normalised: '${normalised}') ≠ filename '${filename}'"
          hint "Change name to: name: $filename"
        else
          pass "name matches filename: $filename"
        fi
      fi

      # ── Check 6: description length ─────────────────────────────────────────
      if [[ "$field" == "description" ]]; then
        local desc_len
        desc_len=${#value}
        if (( desc_len < MIN_DESC_CHARS )); then
          fail "description too short: ${desc_len} chars (minimum ${MIN_DESC_CHARS})"
          hint "Expand description to at least 50 characters — explain what the skill does and when to use it"
        elif (( desc_len > MAX_DESC_CHARS )); then
          fail "description too long: ${desc_len} chars (maximum ${MAX_DESC_CHARS})"
          hint "Trim description to under 300 characters"
        else
          pass "description length OK: ${desc_len} chars"
        fi
      fi

      # ── Check 7: version format ──────────────────────────────────────────────
      if [[ "$field" == "version" ]]; then
        if ! valid_version "$value"; then
          fail "version format invalid: '$value' (expected e.g. 1.0 or 1.0.1)"
          hint "Change to: version: \"1.0\""
        else
          pass "version format OK: $value"
        fi
      fi
    fi
  done

  # ── Check 8: Skill-specific section checks ──────────────────────────────────
  if $is_skill; then
    check_skill_sections "$filepath"
  fi
}

# ── Skill Section Validator ───────────────────────────────────────────────────
check_skill_sections() {
  local filepath="$1"
  for section in "${REQUIRED_SKILL_SECTIONS[@]}"; do
    if grep -q "^${section}" "$filepath"; then
      pass "Section found: ${section}"
    else
      fail "Missing required section: ${section}"
      hint "Add a '${section}' heading to the file"
    fi
  done
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${BLUE}  Militant Foodie — Skill Validator${RESET}"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "  Repo:     $REPO_ROOT"
echo -e "  Mode:     $( $SKILLS_ONLY && echo 'skills/ only' || echo 'all .md files' )"
echo -e "  Hints:    $( $FIX_HINTS && echo 'on' || echo 'off (use --fix-hints to enable)' )"

# ── Structure ─────────────────────────────────────────────────────────────────
if ! $SKILLS_ONLY; then
  check_structure
fi

# ── Validate skills/ ──────────────────────────────────────────────────────────
if [[ -d "$SKILLS_DIR" ]]; then
  header "🛠   Skills (skills/*.md)"
  while IFS= read -r -d '' f; do
    validate_file "$f" true
  done < <(find "$SKILLS_DIR" -name "*.md" -print0 | sort -z)
fi

# ── Validate root .md files ───────────────────────────────────────────────────
if ! $SKILLS_ONLY; then
  header "📋  Root Files"
  while IFS= read -r -d '' f; do
    validate_file "$f" false
  done < <(find "$REPO_ROOT" -maxdepth 1 -name "*.md" -print0 | sort -z)
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}  Summary${RESET}"
echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${RESET}"
echo -e "  Files checked:  ${TOTAL}"
echo -e "  ${GREEN}Passed:${RESET}         ${PASSED}"
echo -e "  ${RED}Failed:${RESET}         ${FAILED}"
echo -e "  ${YELLOW}Warnings:${RESET}       ${WARNINGS}"

if (( ${#FAILURE_SUMMARY[@]} > 0 )); then
  echo -e "\n${RED}${BOLD}Failures:${RESET}"
  for f in "${FAILURE_SUMMARY[@]}"; do
    echo -e "  ${RED}✗${RESET}  $f"
  done
fi

if (( ${#WARNING_SUMMARY[@]} > 0 )); then
  echo -e "\n${YELLOW}${BOLD}Warnings:${RESET}"
  for w in "${WARNING_SUMMARY[@]}"; do
    echo -e "  ${YELLOW}⚠${RESET}  $w"
  done
fi

echo ""
if (( FAILED == 0 )); then
  echo -e "${GREEN}${BOLD}  ✓ All checks passed.${RESET}\n"
  exit 0
else
  echo -e "${RED}${BOLD}  ✗ ${FAILED} check(s) failed. Run with --fix-hints for guidance.${RESET}\n"
  exit 1
fi
