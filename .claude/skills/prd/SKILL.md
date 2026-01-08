---
name: prd
description: Generate detailed Product Requirements Documents (PRDs) for features. Use this skill when starting a new feature to create a clear specification before implementation.
---

# PRD Skill

Generate detailed Product Requirements Documents for AI-assisted development.

## Purpose

Create clear, actionable PRDs that can be converted to user stories for autonomous implementation by Ralph.

## Workflow

1. **Receive feature request** from user
2. **Ask clarifying questions** (3-5 max, with lettered options)
3. **Generate PRD** in markdown format
4. **Save to** `tasks/prd-[feature-name].md`

## Clarifying Questions Format

Ask only the most critical questions. Provide options for easy selection:

```
1. What is the primary goal of this feature?
   A. Improve user experience
   B. Add new functionality
   C. Fix existing issues
   D. Performance improvement

2. Who is the target user?
   A. All users
   B. Admin users only
   C. New users
   D. Power users

3. What is the priority/timeline?
   A. Urgent (1-2 weeks)
   B. High priority (3-4 weeks)
   C. Standard (1-2 months)
   D. Future consideration
```

User can respond with: "1A, 2C, 3B"

## PRD Structure

Generate PRDs with these sections:

```markdown
# PRD: [Feature Name]

## Overview
Brief description of the feature and the problem it solves.

## Goals
- Specific, measurable objective 1
- Specific, measurable objective 2

## User Stories
High-level user narratives:
- As a [user type], I want to [action] so that [benefit]

## Functional Requirements
Numbered list of specific functionalities:
1. The system must...
2. The system should...

## Non-Goals (Out of Scope)
What this feature will NOT include.

## Design Considerations
- UI/UX requirements
- Component reuse
- Responsive behavior

## Technical Considerations
- Dependencies
- Database changes
- API changes
- Performance requirements

## Acceptance Criteria
How we know the feature is complete:
- [ ] Criterion 1
- [ ] Criterion 2

## Branch Name Suggestion
`feature/[descriptive-name]` or `ralph/[feature-name]`
```

## Guidelines

- Keep requirements specific and testable
- Each requirement should be implementable in one context window
- Include "typecheck passes" in acceptance criteria for TypeScript projects
- Include "Verify in browser" for UI features
- Suggest a branch name following the pattern `ralph/[feature-name]`

## Example Usage

User: "Create a PRD for adding dark mode to the app"

Response:
1. Ask 3-4 clarifying questions with options
2. Generate PRD based on answers
3. Save to `tasks/prd-dark-mode.md`
4. Suggest next step: "Now use the ralph skill to convert this to prd.json"
