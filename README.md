# Ralph Loop for Claude Code

An autonomous AI agent loop that runs Claude Code repeatedly until all PRD items are complete. Adapted from [snarktank/ralph](https://github.com/snarktank/ralph) for use with Claude Code instead of Amp.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/claude-code) installed and authenticated
- `jq` installed (`brew install jq` on macOS, `apt install jq` on Linux)
- A git repository for your project

## Quick Start

### 1. Copy files to your project

```bash
# From your project root
mkdir -p scripts/ralph
cp /path/to/ralph-claude-code/scripts/ralph/ralph.sh scripts/ralph/
cp /path/to/ralph-claude-code/scripts/ralph/prompt.md scripts/ralph/
chmod +x scripts/ralph/ralph.sh
```

### 2. Install skills

Skills must be in a `.claude/skills/` directory. You have two options:

**Option A: Project-level (recommended)**
```bash
# From your project root
mkdir -p .claude/skills/prd .claude/skills/ralph
cp /path/to/ralph-claude-code/skills/prd/SKILL.md .claude/skills/prd/
cp /path/to/ralph-claude-code/skills/ralph/SKILL.md .claude/skills/ralph/
```

**Option B: Global (available in all projects)**
```bash
mkdir -p ~/.claude/skills/prd ~/.claude/skills/ralph
cp /path/to/ralph-claude-code/skills/prd/SKILL.md ~/.claude/skills/prd/
cp /path/to/ralph-claude-code/skills/ralph/SKILL.md ~/.claude/skills/ralph/
```

### 3. Create a PRD

Use the PRD skill to generate a detailed requirements document:

```bash
claude "Load the prd skill and create a PRD for [your feature description]"
```

Answer the clarifying questions. The skill saves output to `tasks/prd-[feature-name].md`.

### 4. Convert PRD to Ralph format

Use the Ralph skill to convert the markdown PRD to JSON:

```bash
claude "Load the ralph skill and convert tasks/prd-[feature-name].md to prd.json"
```

This creates `prd.json` with user stories structured for autonomous execution.

### 5. Run Ralph

```bash
./scripts/ralph/ralph.sh [max_iterations]
```

Default is 10 iterations. For larger features, use 25-50.

## What Ralph Does

Each iteration, Ralph will:

1. Create/checkout the feature branch (from `branchName` in prd.json)
2. Pick the highest priority story where `passes: false`
3. Implement that single story
4. Run quality checks (typecheck, tests)
5. Commit if checks pass
6. Update `prd.json` to mark story as `passes: true`
7. Append learnings to `progress.txt`
8. Repeat until all stories pass or max iterations reached

## File Structure

```
your-project/
├── .claude/
│   └── skills/            # Project-level skills (or use ~/.claude/skills/ for global)
│       ├── prd/
│       │   └── SKILL.md
│       └── ralph/
│           └── SKILL.md
├── scripts/ralph/
│   ├── ralph.sh          # The bash loop script
│   └── prompt.md         # Instructions for each iteration
├── prd.json              # User stories with passes status
├── progress.txt          # Append-only learnings (created by Ralph)
├── .last-branch          # Tracks current feature branch
└── archive/              # Previous runs (auto-created)
```

## Key Files

| File | Purpose |
|------|---------|
| `ralph.sh` | The bash loop that spawns fresh Claude Code instances |
| `prompt.md` | Instructions given to each Claude Code instance |
| `prd.json` | User stories with `passes` status (the task list) |
| `progress.txt` | Append-only learnings for future iterations |
| `.claude/skills/prd/` | Skill for generating PRDs |
| `.claude/skills/ralph/` | Skill for converting PRDs to JSON |

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a **new Claude Code instance** with clean context. Memory persists only via:

- Git history (commits from previous iterations)
- `progress.txt` (learnings and context)
- `prd.json` (which stories are done)

### Small Tasks

Each story should be completable in one context window. If a task is too big, Claude runs out of context before finishing.

**Right-sized stories:**
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

**Too big (split these):**
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### Feedback Loops

Ralph only works with feedback loops:
- Typecheck catches type errors
- Tests verify behavior
- CI must stay green

### Stop Condition

When all stories have `passes: true`, Ralph outputs `<promise>COMPLETE</promise>` and exits.

## Debugging

```bash
# See which stories are done
cat prd.json | jq '.userStories[] | {id, title, passes}'

# See learnings from previous iterations
cat progress.txt

# Check git history
git log --oneline -10
```

## Security Warning

⚠️ **Running with `--dangerously-skip-permissions` gives Claude Code full control over your terminal and filesystem.** 

Recommended safety measures:
- Run in a sandboxed environment or VM
- Use a dedicated branch
- Review commits before merging
- Set reasonable `max_iterations` limits

## Tips

1. **Start small** - Begin with 10 iterations to test
2. **Review prd.json** - Ensure stories are right-sized before running
3. **Watch the first iteration** - Make sure it's working correctly
4. **Check progress.txt** - See what Ralph learned
5. **Iterate on prompt.md** - Customize for your project's conventions

## References

- [Original Ralph (Amp version)](https://github.com/snarktank/ralph)
- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [Claude Code documentation](https://docs.anthropic.com/claude-code)
