# ADR 0005: Database Schema Design

Status: Accepted
Date: April 2026

## Context

The product is being built with the explicit goal of having a real, growable foundation rather than a vibe-coded prototype. The schema needs to support v1 functionality while also accommodating v1.1 (yearly seasonality view), v2 (invoice ingestion), and beyond, without rewrite.

The schema also needs to capture the difference between:
- Human-verified expert content (ground truth, slow to grow)
- LLM-inferred content (fast to generate, lower confidence)
- Imported reference data (USDA, BLS, etc.)
- Computed rollups (seasonality patterns derived from price history)

## Decision

A 27-table relational schema in PostgreSQL via Supabase. Major design choices:

### Granular ingredients
Ingredients are stored at a level of specificity that matters for cooking and pricing. "Chicken thigh, bone-in, skin-on" is a separate row from "chicken thigh, boneless, skinless." This produces more rows but more accurate substitution reasoning.

### Roles as a separate table, joined per recipe
Ingredient roles (structural aromatic base, primary protein, etc.) are first-class entities. Role is captured per `recipe_ingredient`, not per ingredient, because the same ingredient plays different roles in different dishes.

### Dish archetypes for cross-cultural translation
Dishes are linked to an archetype (e.g., starch-egg-richfat-aromatic). Archetypes have role requirements. This enables queries like "show me dishes with the same archetype across different cuisines," powering cross-cultural substitution and exploration.

### Technique as a first-class concept
Cooking methods, equipment, techniques (compositions of method + equipment + conditions), technique outcomes, and sensory doneness cues are modeled separately. This captures things like "wok hei requires a carbon steel wok on a high-BTU gas burner; an induction plate cannot produce it." Substitutions can be technique swaps as well as ingredient swaps.

### Provenance everywhere
Every content table has a `provenance` column with values from a controlled enum. This is the core discipline that makes the LLM-augmented content model honest.

### Substitutions are role-scoped and purpose-tagged
A substitution row links two ingredients in the context of a role (and optionally a cuisine). The substitution has a purpose (cost_reduction, quality_improvement, etc.) so the agent can filter by user intent. Substitution kind can be ingredient_swap, technique_swap, or combined.

### Flavor structured but light
Flavor is captured along 8 dimensions (sweet, salty, sour, bitter, umami, fat, heat, aromatic_intensity) per ingredient. Plus a separate `adjustment_guidance` table for "what to do when a dish is too salt/too sour/etc." Heavier flavor compound modeling is deferred.

### User corrections as first-class data
Every user disagreement (with role inference, substitution quality, cost estimate, availability) is captured as a row in `user_corrections`. Original and corrected values are stored as jsonb. This is the engine for ontology growth post-v1.

## Consequences

**Positive:**
- Real foundation. v1.1 and v2 features fit without schema rewrite.
- Provenance discipline preserves trust as content grows.
- Cross-cultural and technique-aware reasoning are differentiated capabilities most competitors do not have.
- Schema enables meaningful queries (e.g., "dishes that use ingredient X in role Y across cuisines").

**Negative:**
- 27 tables is more upfront design than most v1 products start with.
- Seed content burden is real: every domain (roles, archetypes, techniques, flavors) needs hand-curated starter rows.
- Some tables will be sparse for a while (e.g., `dish_relationships`, `ingredient_technique_results`).
- Joins are deeper than they would be in a denormalized design.

**Mitigation:**
- Seed content scope for v1 is intentionally small (minimum viable per milestone 1).
- Indexes are placed on the join paths that runtime queries will use most.
- The schema is designed so missing rows degrade gracefully (LLM reasoning fills gaps) rather than breaking the runtime.

## Alternatives considered

**Flat YAML files for ingredients and substitutions.** Rejected after pushback from Lee. Flat files are fine for throwaway prototypes; this is meant to be a foundation. A real schema in a real database is the right call.

**Document-oriented (MongoDB or similar).** Rejected. The relational structure of ingredient-role-dish-recipe is genuinely relational. Document storage would require denormalization that loses the queryable structure we need.

**Schema generated at runtime from LLM.** Considered briefly and rejected. LLM-generated schemas are not reliable foundations.

**Smaller starter schema (15 tables) with future expansion.** Considered. Rejected because the additions (technique layer, archetypes, flavor descriptors, provenance richness) all came up in design conversation as load-bearing for capabilities Lee wanted. Adding them later would require migrations and possibly data backfills.

## See also

- The actual SQL that built this schema is preserved in the conversation history that produced ADR 0005. If we need to recreate the schema from scratch, the SQL should be reconstituted from the conversation and committed as `migrations/0001_initial_schema.sql`.
- Schema visualization can be generated from Supabase's built-in tools.
