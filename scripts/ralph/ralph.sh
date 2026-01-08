#!/usr/bin/env bash
# Ralph Loop for Claude Code
# Adapted from snarktank/ralph for use with Claude Code instead of Amp
# Original: https://github.com/snarktank/ralph

set -e

MAX_ITERATIONS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🐛 Ralph Loop for Claude Code${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check prerequisites
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed. Install with: brew install jq${NC}"
    exit 1
fi

if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code CLI not found.${NC}"
    echo "Install from: https://docs.anthropic.com/claude-code"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

# Check for required files
if [ ! -f "prd.json" ]; then
    echo -e "${RED}Error: prd.json not found in project root${NC}"
    echo "Create one using: claude 'Load the prd skill and create a PRD for [your feature]'"
    exit 1
fi

# Archive previous run if branch changed
BRANCH_NAME=$(jq -r '.branchName' prd.json)
if [ -f ".last-branch" ]; then
    LAST_BRANCH=$(cat .last-branch)
    if [ "$LAST_BRANCH" != "$BRANCH_NAME" ] && [ -f "progress.txt" ]; then
        echo -e "${YELLOW}Archiving previous run ($LAST_BRANCH)...${NC}"
        ARCHIVE_DIR="archive/$(date +%Y-%m-%d)-${LAST_BRANCH//\//-}"
        mkdir -p "$ARCHIVE_DIR"
        [ -f "progress.txt" ] && cp progress.txt "$ARCHIVE_DIR/"
        [ -f "prd.json.bak" ] && cp prd.json.bak "$ARCHIVE_DIR/prd.json"
        rm -f progress.txt
    fi
fi
echo "$BRANCH_NAME" > .last-branch

# Create or checkout feature branch
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
    echo -e "${YELLOW}Checking out existing branch: $BRANCH_NAME${NC}"
    git checkout "$BRANCH_NAME"
else
    echo -e "${GREEN}Creating new branch: $BRANCH_NAME${NC}"
    git checkout -b "$BRANCH_NAME"
fi

# Initialize progress.txt if it doesn't exist
if [ ! -f "progress.txt" ]; then
    echo "# Ralph Progress Log" > progress.txt
    echo "# Branch: $BRANCH_NAME" >> progress.txt
    echo "# Started: $(date)" >> progress.txt
    echo "" >> progress.txt
    echo "## Codebase Patterns" >> progress.txt
    echo "(Discovered patterns will be added here)" >> progress.txt
    echo "" >> progress.txt
    echo "## Session Log" >> progress.txt
fi

echo ""
echo -e "${GREEN}Starting Ralph Loop (max $MAX_ITERATIONS iterations)${NC}"
echo ""

# Main loop
for i in $(seq 1 $MAX_ITERATIONS); do
    echo -e "${GREEN}═══ Iteration $i of $MAX_ITERATIONS ═══${NC}"
    
    # Check if all stories are complete before running
    INCOMPLETE=$(jq '[.userStories[] | select(.passes == false)] | length' prd.json)
    if [ "$INCOMPLETE" -eq 0 ]; then
        echo -e "${GREEN}✅ All stories complete!${NC}"
        echo "<promise>COMPLETE</promise>"
        exit 0
    fi
    
    echo "Remaining stories: $INCOMPLETE"
    echo ""
    
    # Run Claude Code with the prompt
    # --dangerously-skip-permissions allows autonomous operation
    OUTPUT=$(cat "$SCRIPT_DIR/prompt.md" \
        | claude --dangerously-skip-permissions 2>&1 \
        | tee /dev/stderr) || true
    
    # Check for completion signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo ""
        echo -e "${GREEN}✅ Ralph completed all stories!${NC}"
        exit 0
    fi
    
    # Brief pause between iterations
    sleep 2
done

echo ""
echo -e "${YELLOW}⚠️ Max iterations ($MAX_ITERATIONS) reached${NC}"
echo "Check progress.txt and prd.json for current state"
exit 1
