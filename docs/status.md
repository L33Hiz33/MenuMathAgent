# Status

Updated at the end of each working session. Five minutes of writing per session pays for itself many times over.

## Format

Each entry is dated. Each entry has three sections:

- **What got done.** Concrete completed work.
- **What is blocked or open.** Things waiting on a decision, an external dependency, or that hit unexpected friction.
- **What is next.** The first thing to do in the next session.

## Sessions

### Saturday, April 26 (afternoon and evening)

**What got done:**
- Conversation established product brief, v1 spec, and architectural direction
- Repo scaffolded at `C:\Users\hisey\recipe-advisor\` with planning artifact stubs
- Git initialized, first commit made
- Schema designed across multiple conversational rounds, locked at 27 tables
- Schema deployed to Supabase successfully
- All planning documents written and committed (README, CLAUDE.md, spec-v1, ADRs 0001 through 0006, milestones, risks, this status file)
- Schema captured as `migrations/0001_initial_schema.sql` and committed (commit 8d9db95). Removes dependency on chat history for schema reproducibility.
- Role taxonomy stress-tested against 5 real dishes: gumbo, beef Wellington, banh mi, Neapolitan margherita pizza, turducken. Stress tests revealed substantial gaps in the initial role list and two missing schema concepts.

**Role list expanded to roughly 37 roles** (final list to be locked tomorrow when seed file is created). Major additions from stress tests:

- liquid_base, thickening_agent, aromatic_infusion (gumbo)
- concentrated_flavor_paste, barrier_enclosure_layer, pastry_dough_enclosure, surface_treatment, composed_sauce (Wellington)
- spread_component, pickled_acid_component, bread_enclosure (banh mi; bread_enclosure kept distinct from pastry_dough_enclosure per Lee's call)
- structural_dairy_component, finishing_dairy_component (pizza)
- interstitial_layer / structural_stuffing (turducken)
- headlining_protein replaces primary_protein, supporting_protein replaces secondary_protein, multiple of either allowed per dish

**Schema gaps identified during stress testing, NOT yet built:**

1. **Sub-recipe references.** Recipes cannot currently reference other recipes as components. Turducken (chicken-in-duck-in-turkey, plus dressings) and most non-trivial real recipes (sauces, stocks, dressings) need this. Migration 0003 needed: `recipe_sub_recipes` join table.

2. **Dish pairings with metadata.** Companion dishes that complete a dish at service (potato salad on gumbo, naan with dal, crema on tinga). Lee specifically called out the "1+1=11" effect. Migration 0003 needed: `dish_pairings` table with contrast_dimensions, synergy_notes, popularity_tier.

3. **Pastry roles ready but not yet validated against a real pastry dish.** Could stress-test against a tarte tatin or croissant tomorrow if time allows. Risk: pastry roles may need revision once tested.

**What is blocked or open:**
- Stack decisions still open: front-end framework, backend framework. Tracked in ADRs 0003.
- USDA terminal market report data source not yet evaluated for parser feasibility.
- Migration 0003 (recipe_sub_recipes, dish_pairings) drafted conceptually but not yet written or run.

**What is next:**

Tomorrow morning's first session, in Claude Code:

1. **First task: write and apply migration 0003.** New tables for recipe sub-recipes and dish pairings. Specs are in this file under "Schema gaps identified during stress testing." Apply to Supabase. Commit the migration file.

2. **Second task: begin Milestone 1 seed content.** Start with the role taxonomy (~37 roles, names and one-sentence definitions, all with `human_verified_expert` provenance). Generate as a SQL file `migrations/0002_seed_roles.sql` (numbered before the schema additions because roles are referenced by other tables). Run against Supabase. Verify rows are present.

   NOTE on numbering: tonight we committed `0001_initial_schema.sql`. The seed roles SQL should be `0002_seed_roles.sql` and the new tables migration should be `0003_recipe_sub_recipes_and_pairings.sql`. This ordering is important: roles before any seed content that references roles, but after the initial schema.

3. **Third task: Ingredient Knowledge Agent skeleton (Milestone 2).** Node or Python script that connects to Supabase using service role from environment variables (NOT hardcoded). Given a dish name, generates candidate rows for ingredients, dish_ingredient_roles, and substitutions, all with `llm_inferred_low_confidence` provenance. Lee reviews in Supabase Table Editor and promotes accepted rows to verified.

   Stop and confirm with Lee before writing actual database mutations from the agent. First version should be dry-run only, printing what it would write, not writing anything.

4. **Fourth task (if time): seed 5 to 10 dishes Lee knows cold.** Hand-curated, verified provenance. Probably gumbo, beef Wellington, banh mi (since we walked them), plus a couple of food-truck-relevant dishes (al pastor tacos, a ramen, something else).

End of Sunday goal: ~37 roles in database, schema for sub-recipes and pairings deployed, agent skeleton working in dry-run mode, 5 to 10 dishes seeded.

### Sunday, April 27

**What got done:**
- Migration 0003 written, applied to Supabase, and committed: `recipe_sub_recipes` and `dish_pairings` tables added, plus `pairing_popularity_tier` enum and triggers.
- Schema now at 29 tables.
- Five commits during this session.

**What is blocked or open:**
- Role taxonomy still being refined, not yet locked.
- Migration 0002 (role taxonomy seed) deferred to next session pending role list lock.

**What is next:**
- Lock role taxonomy.
- Write and apply migration 0002.

### Tuesday, April 28

**What got done:**
- Project documentation review session.
- Working agreement, voice, and operating discipline rules consolidated into Project Knowledge for chat continuity.
- Role taxonomy work continued: identified gaps including bulk vs signature vegetable split (likely fake), need for ingredient_aliases and substitution_purpose status verification, sauces and condiments deferral.

**What is blocked or open:**
- Role taxonomy still not locked. Approximately 22 to 25 roles drafted of an estimated 37.
- Migration 0002 still pending lock.

**What is next:**
- Verify schema state in Supabase before any further work.
- Lock the role taxonomy.

### Wednesday, April 29

**What got done:**
- **Schema verification:** ran direct queries against Supabase to verify true state. Confirmed 29 tables (not 27 as some docs suggested). Confirmed `ingredient_aliases` and `substitution_purpose` enum already committed in migration 0001 (earlier docs incorrectly said "proposed"). Confirmed full enum list, foreign keys, indexes, and unique constraints. All FK wiring for `ingredient_roles` is in place across `recipe_ingredients`, `dish_ingredient_roles`, `dish_archetype_components`, `recipe_sub_recipes`, `substitutions`.
- **Schema scope acknowledgment:** the schema includes more tables than v1 strictly needs (techniques, equipment, cooking_methods, dish_archetypes, flavor_attributes, sensory_doneness_cues, adjustment_guidance). These remain empty and unused by v1 engine. Documented in CLAUDE.md and spec docs as v1 vs post-v1 subsets.
- **Role taxonomy locked at 36 roles** via migration `0002_role_taxonomy_seed.sql`. Provenance: `human_verified_expert`. Stress-tested against gumbo, banh mi, Wellington, margherita, turducken, Thai green curry, and mole poblano. Final list reflects:
  - Slot-based framework: roles are SLOTS named by their FUNCTION; sub-recipes fill slots; substitutions are alternative slot-fillers
  - `starch_thickener` renamed to `thickening_agent` (covers nuts, bread, starches, all thickening mechanisms)
  - `bulk_vegetable` and `signature_vegetable` collapsed into single `vegetable_substance`
  - New roles added: `sauce_body`, `flavor_paste`, `pickle_component`, `condiment_component`, `sauce_component`, `dressing_component`, `glaze_component`, `coating_dry`, `emulsifier`, `smoke_component`, `other_component` (catch-all)
  - Multi-function ingredients use primary role + notes, NOT multiple rows
- **Engine architecture decided: A+B.** Human-reviewed LLM seed (A) provides ground truth and rails for runtime LLM research engine (B). Build A first using B with human review at every row, then run B at runtime against seeded foundation.
- **Documentation reconciliation:** identified that disk docs and claude.ai Project Knowledge had duplicated and drifted documentation. Decision: disk docs are authoritative single source of truth. Project Knowledge files in claude.ai will be deleted. Stale disk docs (CLAUDE.md, status.md, risks.md, milestones.md, ADR 0005) updated to reflect current state.

**What is blocked or open:**
- Engine prompt design (B): not started. Will be designed in claude.ai chat (not Claude Code) before implementation.
- Catch-all monitoring view (migration 0004): planned but deferred. Lee requested periodic execution + email-report mechanism for catch-all pattern review. Not v1-blocking but should exist before runtime engine generates significant catch-all data.
- Substitutions table has no unique constraint on (original_ingredient_id, substitute_ingredient_id, role_id, substitution_purpose). Application logic must dedupe before insert. Schema fix deferred.
- Ingredient_aliases.alias_name is indexed but not unique. Same alias could map to two ingredients. Schema fix deferred.
- Dishes table has no unique constraint on (name, cuisine_id). Schema fix deferred.
- Dish-scoped substitutions (Option 2): schema change to add optional `dish_id` FK to substitutions table. Decided in principle, deferred until v1 build hits real failures with current cuisine + role scoping.

**What is next:**

1. **Engine prompt design (in claude.ai chat).** The runtime LLM research engine prompt that:
   - Pulls 36 role names and descriptions from `ingredient_roles` at runtime
   - Decomposes a recipe (or dish name) into ingredients with role assignments
   - Identifies and recursively decomposes sub-recipes
   - Marks new rows with `llm_inferred_*` provenance
   - Returns substitution suggestions scoped by role
   - Uses notes for multi-function ingredients

2. **Ingredient Knowledge Agent skeleton (Milestone 2).** Python script connecting to Supabase via service role from environment variables (NOT hardcoded). Dry-run mode first. Lee reviews output before any database mutations.

3. **Begin seeding (Milestone 1 continuation).** Use the engine to research and propose ingredient and substitution rows for a small set of food-truck-relevant dishes. Human review every row before commit.

4. **Continue stack decisions:** front-end framework, backend hosting, exact Claude model.

End of week 1 goal stands: viable v1 demo with at least one real recipe parsed end-to-end using real USDA market data.
