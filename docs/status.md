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
