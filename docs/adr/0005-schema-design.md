# ADR 0005: Database Schema Design

Status: Accepted
Date: April 2026 (initial); updated 2026-04-29 to reflect migrations 0002 and 0003

## Context

The product is being built with the explicit goal of having a real, growable foundation rather than a vibe-coded prototype. The schema needs to support v1 functionality while also accommodating v1.1 (yearly seasonality view), v2 (invoice ingestion), and beyond, without rewrite.

The schema also needs to capture the difference between:
- Human-verified expert content (ground truth, slow to grow)
- LLM-inferred content (fast to generate, lower confidence)
- Imported reference data (USDA, BLS, etc.)
- Computed rollups (seasonality patterns derived from price history)

## Decision

A 29-table relational schema in PostgreSQL via Supabase. Migrations applied as of April 29, 2026:

- **0001_initial_schema.sql** (April 26): 27 tables, all FKs, indexes, triggers, full enum set
- **0002_role_taxonomy_seed.sql** (April 29): seeded `ingredient_roles` with the 36 locked canonical roles, all `human_verified_expert` provenance
- **0003_recipe_sub_recipes_and_pairings.sql** (April 27): added `recipe_sub_recipes` and `dish_pairings` tables, plus `pairing_popularity_tier` enum

Major design choices:

### Granular ingredients
Ingredients are stored at a level of specificity that matters for cooking and pricing. "Chicken thigh, bone-in, skin-on" is a separate row from "chicken thigh, boneless, skinless." This produces more rows but more accurate substitution reasoning.

### Roles as a separate table, joined per recipe, locked at 36
Ingredient roles are first-class entities. Role is captured per `recipe_ingredient`, not per ingredient, because the same ingredient plays different roles in different dishes.

The role list was locked April 29, 2026 at 36 canonical roles via migration 0002. Stress-tested against gumbo, banh mi, beef Wellington, Neapolitan margherita pizza, turducken, Thai green curry, and mole poblano.

The locking framework: roles are SLOTS named by their FUNCTION in the parent recipe, not by what the ingredient physically is. Sub-recipes (via `recipe_sub_recipes`) FILL slots. Substitutions are alternative slot-fillers. The same sub-recipe can play different roles in different parent recipes (mayo plays `condiment_component` in banh mi, `binder` in lobster roll).

The 36 roles span: proteins (2), fats (3), starches and structure (4), liquids (3), sauce body (1), aromatics and flavor matrix (3), spice and seasoning (4), umami/heat/sweet/smoke (4), texture/structure/function (5), vegetables (1), composed components (5), catch-all (1). Catch-all (`other_component`) requires notes describing what the ingredient is doing; pattern-review monitoring (planned migration 0004) surfaces recurring catch-all uses for promotion.

Multi-function ingredients (chipotle = umami + heat + smoke; Mexican chocolate = umami + fat + sweet + spice) use primary role + notes, NOT multiple rows. This keeps queries simple and prevents data fragmentation.

### Sub-recipes as first-class
Recipes can reference other recipes as components via `recipe_sub_recipes`. Added in migration 0003. Most non-trivial recipes (sauces, stocks, pastry creams, marinades, pickles, stuffings, complete sub-dishes like turducken's nested proteins) need this. Each sub-recipe link captures: parent recipe, sub-recipe, role the sub-recipe plays in the parent, quantity, unit, step order, optional flag, notes, provenance.

Cycle prevention enforced in application code (CHECK constraint cannot catch multi-hop cycles).

### Dish pairings as first-class
Dish-to-dish pairings (potato salad alongside gumbo, naan with dal, crema on tinga) captured in `dish_pairings`. Added in migration 0003. Tracks: primary dish, paired dish, contrast dimensions (text array), synergy notes, popularity tier (universal, regional, insider_knowledge, innovative).

This was the structural pattern Lee called out as "1+1=11" effect: two complete dishes that combine to be greater than the sum of parts.

### Dish archetypes for cross-cultural translation (post-v1)
Dishes can be linked to an archetype (e.g., starch-egg-richfat-aromatic). Archetypes have role requirements via `dish_archetype_components` (with `role_requirement` enum: required, optional, forbidden, characterizing). This enables queries like "show me dishes with the same archetype across different cuisines," powering cross-cultural substitution and exploration.

Tables exist but are empty in v1. Feature is post-v1.

### Technique as a first-class concept (post-v1)
Cooking methods (`cooking_methods` with `cooking_method_category` enum), equipment (`equipment` with `equipment_type` enum and thermal property fields), techniques (compositions of method + primary equipment + secondary equipment + temperature range + duration + difficulty), technique outcomes, and sensory doneness cues are modeled separately. This captures things like "wok hei requires a carbon steel wok on a high-BTU gas burner; an induction plate cannot produce it." Substitutions can reference an alternative technique via `substitutions.alternative_technique_id`.

Tables exist but are empty in v1. Feature is post-v1.

### Provenance everywhere
Every content table has a `provenance` column with values from a controlled enum:
- `human_verified_expert`
- `human_verified_community`
- `human_submitted_unverified`
- `llm_inferred_high_confidence`
- `llm_inferred_low_confidence`
- `imported_from_source`
- `derived_computed`

This is the core discipline that makes the LLM-augmented content model honest.

### Substitutions are role-scoped and purpose-tagged
A substitution row links two ingredients in the context of a role (and optionally a cuisine). The substitution has a purpose (`substitution_purpose` enum: cost_reduction, quality_improvement, availability_swap, dietary_restriction, technique_simplification, cuisine_translation) so the agent can filter by user intent. Substitution kind can be `ingredient_swap`, `technique_swap`, or `combined`. Cost direction is `cheaper`, `similar`, `more_expensive`, or `variable`.

Open issue: no unique constraint on `(original_ingredient_id, substitute_ingredient_id, role_id, substitution_purpose)`. Application logic must dedupe before insert. Schema fix deferred.

Open issue (deferred): adding optional `dish_id` FK to substitutions for dish-scoped substitution rules (decided April 29 but deferred until v1 build hits real failures).

### Flavor structured but light (post-v1)
Flavor is captured along 8 dimensions (`flavor_dimension` enum: sweet, salty, sour, bitter, umami, fat, heat, aromatic_intensity) per ingredient via `flavor_attributes`. Plus a separate `adjustment_guidance` table (with `adjustment_direction` enum: too_much, too_little) for "what to do when a dish is too salty/too sour/etc."

Tables exist but are empty in v1. Feature is post-v1.

### User corrections as first-class data
Every user disagreement (with role inference, substitution quality, cost estimate, availability, technique match) is captured as a row in `user_corrections`. Original and corrected values are stored as jsonb. Captures user_session_id for anonymous users. `correction_type` enum: role_inference, substitution_quality, cost_estimate, availability, technique_match, other.

This is the engine for ontology growth post-v1.

## Consequences

**Positive:**
- Real foundation. v1.1 and v2 features fit without schema rewrite.
- Provenance discipline preserves trust as content grows.
- Cross-cultural and technique-aware reasoning are differentiated capabilities most competitors do not have (post-v1).
- Schema enables meaningful queries (e.g., "dishes that use ingredient X in role Y across cuisines").
- Slot-based role framework (locked April 29) allows substitution engine to reason about "what kind of thing fills this slot" independent of "what specific implementation is in the recipe."

**Negative:**
- 29 tables is more upfront design than most v1 products start with. Some tables (technique layer, dish archetypes, flavor attributes, adjustment guidance, sensory cues) are not used by v1 engine and remain empty until post-v1 features are built.
- Seed content burden is real: every domain (roles done, ingredients pending, archetypes deferred, techniques deferred, flavors deferred) needs hand-curated or LLM-then-human-reviewed starter rows.
- Joins are deeper than they would be in a denormalized design.

**Mitigation:**
- Seed content scope for v1 is intentionally small. v1-critical tables only: ingredient_roles (done), ingredients, ingredient_aliases, ingredient_categories, recipes, recipe_ingredients, recipe_sub_recipes, dishes, cuisines, substitutions, market_data_sources, market_prices, users.
- Indexes are placed on the join paths that runtime queries will use most.
- The schema is designed so missing rows degrade gracefully (LLM reasoning fills gaps, marked with `llm_inferred_*` provenance) rather than breaking the runtime.
- Catch-all role and pattern-review monitoring (migration 0004, pending) prevent role taxonomy bloat by surfacing real promotion candidates instead of guessing.

## Alternatives considered

**Flat YAML files for ingredients and substitutions.** Rejected after pushback from Lee. Flat files are fine for throwaway prototypes; this is meant to be a foundation. A real schema in a real database is the right call.

**Document-oriented (MongoDB or similar).** Rejected. The relational structure of ingredient-role-dish-recipe is genuinely relational. Document storage would require denormalization that loses the queryable structure we need.

**Schema generated at runtime from LLM.** Considered briefly and rejected. LLM-generated schemas are not reliable foundations.

**Smaller starter schema (15 tables) with future expansion.** Considered. Rejected because the additions (technique layer, archetypes, flavor descriptors, provenance richness) all came up in design conversation as load-bearing for capabilities Lee wanted. Adding them later would require migrations and possibly data backfills.

**Synonym roles for the same slot.** Considered briefly during the role taxonomy lock (April 29). Rejected. Keeping both `sauce_body` AND `enriching_liquid` as separate roles for the same coconut-milk-in-curry function would fragment data: LLM seeding engine would pick differently across recipes, substitution engine would miss matches across "synonyms," human review would be unable to distinguish real distinction from picker confusion. Locked at one name per slot.

**Multiple rows per ingredient for multi-function cases.** Considered for chipotle (umami + heat + smoke) and Mexican chocolate (umami + fat + sweet + spice). Rejected: fragments data the same way synonym roles do. Resolution: primary role + notes describing other functions.

## See also

- The actual SQL that built this schema is preserved in `migrations/`:
  - `0001_initial_schema.sql`
  - `0002_role_taxonomy_seed.sql`
  - `0003_recipe_sub_recipes_and_pairings.sql`
- Schema visualization can be generated from Supabase's built-in tools.
- Role taxonomy stress-test conversations (in claude.ai chat history) document the reasoning behind each role's existence and definition.
