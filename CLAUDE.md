# CLAUDE.md

Project context for Claude Code. Read this first, every session.

## What this project is

A web-based tool that takes a recipe (freeform text) and a user's location, evaluates the ingredients in their roles within the dish, and returns substitution suggestions grounded in current public market data, regional availability, and seasonality. The user is a food truck operator across the full skill range, from reheat-and-serve to Michelin-aspirational. The tool defaults to cost-reduction substitutions and supports quality-improvement substitutions on request.

The product is also Lee's portfolio piece for a Toast (or comparable industrial SaaS) PM role. It is being built in one focused week.

## Working preferences

These are non-negotiable. They reflect Lee's working style and shortcut a lot of conflict.

- Sparring partner mode. Push back on assumptions, provide counterpoints, prioritize truth over agreement. Call out unchecked assumptions directly.
- Never use em dashes. Use natural punctuation.
- One change at a time. State dependencies explicitly. Do not batch.
- Verify current state before proposing fixes. Read actual files, code, output. Do not pattern-match.
- Pattern: diagnose, then prescribe. When Lee pushes back, articulate what he is pointing at first, confirm the mechanism, then propose.
- If Lee has stated something earlier (constraint, prior attempt, correction), treat it as fact.
- Trace data flow end to end before guessing root cause.
- Do not suggest data sources, RSS feeds, or third-party services unless asked.
- Do not be optimistic about fixes. After proposing a change, list what could still go wrong.
- When rewriting messages for other humans, preserve Lee's voice.
- When a task involves writing more than 10 lines of code or creating files, the work goes in files, not chat output.
- Lee has medium Git comfort. Speak clearly. Do not assume.
- SQL queries use [database].[schema].[table] format, not USE statements.
- Never expose API keys, service role keys, or credentials in plaintext in workflow configs, headers, or code. Use credential stores. Flag security concerns proactively.

## Project state and structure

- Repo root: `C:\Users\hisey\recipe-advisor\`
- Database: Supabase project named "Food Intellegence" (typo in project name preserved, do not rename). Schema is 29 tables. Connection details are in `.env` (not committed).
- Schema files: `migrations/` contains the SQL that built and seeded the database.
  - `0001_initial_schema.sql` (April 26): initial 27-table schema
  - `0002_role_taxonomy_seed.sql` (April 29): 36 ingredient roles seeded
  - `0003_recipe_sub_recipes_and_pairings.sql` (April 27): added `recipe_sub_recipes` and `dish_pairings` tables
- Schema design rationale: `docs/adr/0005-schema-design.md`
- Stack decisions to be made: front-end framework, hosting, LLM provider. Tracked in ADRs 0001 through 0004.

## What v1 does

- User pastes a freeform recipe and selects their state or metro
- Tool parses the recipe into structured ingredients with quantities
- Tool infers each ingredient's role in the dish from the locked 36-role taxonomy and shows the inferred role to the user
- Tool returns substitution suggestions ranked by cost impact and role fidelity, with reasoning visible
- Tool factors current and near-term seasonality and regional availability
- Tool flags uncertainty rather than asserting confidence it does not have

## What v1 explicitly does not do

- Not a recipe builder
- Not an ordering platform
- Not a meal planner, grocery list, or nutrition tracker
- Not integrated with invoice or POS data (that is v2)
- Not a confident long-term price forecaster
- Not, in v1, a yearly menu planner (that is v1.1)

## Six work streams

The project is segmented into six independent streams. Detail in `docs/adr/0006-project-segmentation.md`.

1. Data Layer (schema done, role taxonomy seeded, ingredient and recipe seed pending)
2. Ingredient Knowledge Agent (build-time, populates curated rows)
3. Market Data Agent (fetches USDA, BLS, ERS data)
4. Recipe Reasoning Engine (runtime LLM logic)
5. Front-end and User Experience
6. Deployment, Observability, Operations

## Provenance discipline

Every content row in the database has a `provenance` column with values like `human_verified_expert`, `llm_inferred_high_confidence`, etc. The discipline:

- LLM-generated content goes in with `llm_inferred_*` provenance
- Human-reviewed and accepted content gets promoted to `human_verified_*`
- The Ingredient Knowledge Agent never writes directly as verified
- The runtime engine reads any provenance but signals to the user when reasoning leans on inferred content

Do not bypass this. The whole foundation depends on knowing what is verified versus inferred.

## Engine architecture (decided April 29)

The engine is A+B:

- **A (seed):** human-reviewed LLM output written to the database with appropriate provenance. Ground truth and rails for B.
- **B (runtime):** LLM research engine that takes a recipe or dish name from a user, decomposes it against the seeded foundation, fills gaps with new rows marked `llm_inferred_*`, and returns substitution advisory.

A is built first (using B with human review at every row), then B runs at runtime. Roles are SLOTS named by FUNCTION; sub-recipes fill slots; substitutions are alternative slot-fillers. Multi-function ingredients use primary role + notes (not multiple rows).

## Current focus

(Update this line at the start of every session.)

Current focus: Role taxonomy locked at 36 (migration 0002 applied April 29). Next: design the engine prompt for runtime LLM research, build Ingredient Knowledge Agent skeleton, begin seed of ingredients and substitutions via human-reviewed LLM output.

## How to update CLAUDE.md

When something material changes (a stack decision, a major scope adjustment, a new constraint), update this file. Do not let it drift. Stale CLAUDE.md is worse than no CLAUDE.md.

## Where to find things

- Product brief: `README.md`
- v1 behavior spec: `docs/spec-v1.md`
- Milestones with definition-of-done: `docs/milestones.md`
- Open risks and unknowns: `docs/risks.md`
- Daily status: `docs/status.md`
- Architecture decisions: `docs/adr/`
- Source code (when it exists): `src/`
- Schema migrations: `migrations/`
