# ADR 0006: Project Segmentation

Status: Accepted
Date: April 2026

## Context

The project has multiple concerns that are independent enough to develop and iterate on separately. Treating the whole project as one undifferentiated work effort produces a tangled codebase and constant context-switching. Treating each concern as its own work stream with clear contracts between them allows focused work and graceful failures.

## Decision

The project is segmented into six independent work streams. Each has its own scope, owner, and definition of done. They communicate through the database (which is the contract between streams) rather than through tight coupling.

### Stream 1: Data Layer

**Owns:** The Supabase project, schema migrations, seed content scripts, and the small set of database utilities that other streams need (e.g., Supabase client wrapper).

**Status:** Schema deployed. Seed pending.

**Cross-stream contract:** Other streams read from and write to specific tables with specific provenance markers. They do not modify schema. They do not bypass the provenance discipline.

### Stream 2: Ingredient Knowledge Agent (build-time)

**Owns:** A script or set of scripts (Node or Python) that, given a starting point (a dish name, an ingredient name, a cuisine), generate candidate rows for the curated layer of the database. Output is always written with `llm_inferred_low_confidence` provenance until a human reviews and promotes.

**Runs:** Offline, manually invoked, not part of the runtime path.

**Cross-stream contract:** Writes to `ingredients`, `ingredient_aliases`, `dishes`, `dish_ingredient_roles`, `substitutions`, `flavor_attributes`, etc. Always with appropriate provenance.

### Stream 3: Market Data Agent

**Owns:** Scripts that fetch and parse public market data sources (USDA AMS terminal, BLS CPI, USDA ERS) into the `market_prices` and `seasonality_patterns` tables.

**Runs:** On a schedule (weekly or daily depending on source) or on demand. Not part of the user-facing runtime.

**Cross-stream contract:** Writes to `market_prices` (transactional facts) and updates `market_data_sources.last_fetched_at`. Computes rollups into `seasonality_patterns` periodically.

### Stream 4: Recipe Reasoning Engine

**Owns:** The runtime logic that takes a user request (recipe text + region) and produces the structured output. Includes recipe parsing, ingredient resolution, role inference, substitution generation, and reasoning narrative.

**Runs:** On demand, per user request. Lives behind a backend API endpoint.

**Cross-stream contract:** Reads from most reference tables. Writes to `recipes`, `recipe_ingredients`, `recipe_techniques`, and `user_corrections`. Calls the LLM provider directly.

### Stream 5: Front-end and User Experience

**Owns:** The web UI. Recipe input, region selector, output display, correction capture interactions. State management on the client side.

**Runs:** In the user's browser.

**Cross-stream contract:** Calls the Recipe Reasoning Engine via a backend API. Does not have direct database access (avoids needing service role keys client-side).

### Stream 6: Deployment, Observability, Operations

**Owns:** Hosting (Vercel), environment variables, deployment pipeline, error tracking, basic analytics, the public URL.

**Runs:** Continuously.

**Cross-stream contract:** Provides infrastructure. Other streams deploy through it.

## Consequences

**Positive:**
- Each stream can be worked on independently, with clear boundaries.
- A failure in one stream (e.g., USDA parser breaks) does not block other streams from making progress.
- Different streams have different cadences. The Market Data Agent runs weekly. The Recipe Reasoning Engine runs per request. The Ingredient Knowledge Agent runs when Lee wants to grow content.
- Cross-stream contracts are minimal and explicit (the database tables and their provenance discipline).

**Negative:**
- More upfront thought to keep the boundaries clean.
- Risk of premature abstraction if streams that should share code end up duplicating it.

**Mitigation:**
- Shared utilities (Supabase client, LLM client) live in a `src/lib/` or similar directory and are imported by any stream that needs them.
- The boundaries are guidelines, not religion. If two streams need to share something substantive, they can.

## Sequencing for v1

The streams build out in roughly this order, though they overlap:

1. Data Layer foundation (done) -> seed content (Sunday)
2. Ingredient Knowledge Agent (Sunday, in service of seed content)
3. Market Data Agent (Monday)
4. Recipe Reasoning Engine (Tuesday and Wednesday)
5. Front-end (Tuesday and Wednesday in parallel)
6. Deployment and Operations (Thursday)

Friday is buffer.

## Alternatives considered

**Single-stream development.** Rejected. Conflates concerns, harder to test in isolation, harder to fail gracefully.

**Microservices architecture.** Rejected as overkill for a one-week project with one developer. The streams share a database and that is fine.

**Strict separation with API contracts between streams.** Rejected as too heavy. The shared database is a sufficient contract for v1.
