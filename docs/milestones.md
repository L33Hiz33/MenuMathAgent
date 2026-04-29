# Milestones

Each milestone has a definition of done. A milestone is not complete until every item under "definition of done" is true and demonstrated.

## Milestone 0: Foundation (DONE)

Definition of done:
- [x] Repo created at `C:\Users\hisey\recipe-advisor\`
- [x] Git initialized, initial commit made
- [x] Documentation scaffold in place (README, CLAUDE.md, docs/, ADR stubs)
- [x] Supabase project created (named "Food Intellegence", typo preserved)
- [x] Database schema deployed (29 tables across migrations 0001 and 0003, all FKs, indexes, triggers)
- [x] Product brief and v1 spec written

Completed: Saturday April 26 evening. Migration 0003 (sub-recipes and dish pairings) added Sunday April 27.

## Milestone 1: Curated Seed Content (PARTIAL)

Definition of done:
- [x] Role taxonomy populated (36 roles via migration 0002, all `human_verified_expert` provenance, locked April 29)
- [ ] At least 5 cuisines populated
- [ ] At least 25 ingredients populated with category, role-relevant flavor attributes, and at least one alias each where appropriate
- [ ] At least 5 dishes populated with archetype links and ingredient role requirements
- [ ] At least 30 substitution rows populated, each with role context and cost direction
- [ ] At least 5 dish archetypes populated (deferred: post-v1, dish_archetypes table empty in v1)
- [ ] At least 10 cooking methods and 10 equipment rows populated (deferred: post-v1, technique layer not used in v1 engine)
- [ ] At least 5 techniques populated, with at least 1 sensory cue each (deferred: post-v1)
- [ ] At least 8 adjustment_guidance rows (deferred: post-v1, flavor adjustment layer not used in v1 engine)
- [ ] All seed content has appropriate provenance markers (most are `human_verified_expert` for hand-curated, `llm_inferred_*` for engine-generated awaiting review)

Owner: Lee, with assistance from the Ingredient Knowledge Agent (B engine, used for seeding A with human review on every row).

Original target: end of Sunday April 27. Revised target: end of week 1 for the v1-critical items (cuisines, ingredients, dishes, substitutions). Post-v1 items deferred to v1.1+.

**Note:** the original Milestone 1 list assumed all 27+ tables would be seeded. v1 engine only queries a subset (roles, ingredients, ingredient_aliases, ingredient_categories, recipes, recipe_ingredients, recipe_sub_recipes, dishes, cuisines, substitutions, market_data_sources, market_prices, users). Other tables remain empty until their post-v1 features are built.

## Milestone 2: Ingredient Knowledge Agent (skeleton)

Definition of done:
- [ ] Script (Python) connects to Supabase using service role credentials from environment variables (not hardcoded)
- [ ] Given a dish name or recipe text, agent generates candidate rows for ingredients, recipe_ingredients (with role assignments from the locked 36-role list), and substitutions, all with `llm_inferred_low_confidence` provenance
- [ ] Generated rows include suggested role assignments and substitution candidates
- [ ] Lee can review candidates in the database (via Supabase Table Editor) and promote to verified
- [ ] Agent does not generate duplicate rows for ingredients that already exist (uses canonical_name and aliases for matching)
- [ ] Agent's prompt is designed in claude.ai chat first, then implemented in Claude Code; design includes:
  - Pulling the 36 role names and descriptions from `ingredient_roles` at runtime
  - Recursive sub-recipe decomposition
  - Multi-function ingredient handling via primary role + notes (not multiple rows)
  - Catch-all (`other_component`) used only when no role fits, notes always populated
- [ ] First version is dry-run only: prints what it would write, does not actually write to the database. Lee reviews dry-run output before any mutation logic is enabled.

Owner: Lee, in claude.ai for prompt design, then Claude Code for implementation.

Target: Monday April 28 originally, revised to next session.

## Milestone 3: Market Data Agent (USDA terminal market)

Definition of done:
- [ ] Script fetches current USDA AMS terminal market report for at least one region (Dallas or Atlanta)
- [ ] Parser converts the report into structured rows for `market_prices`
- [ ] At least 10 to 15 of the seeded ingredients have a current price row in their region
- [ ] `market_data_sources` has the source registered with last_fetched_at populated
- [ ] Script can be re-run safely (idempotent for the same date)
- [ ] Errors and parsing failures are logged, not silent

Owner: Lee, in Claude Code.

Target: Monday-Tuesday this week.

## Milestone 4: Recipe Reasoning Engine

Definition of done:
- [ ] Given a recipe text and region, engine returns structured output matching the v1 spec
- [ ] Recipe parser extracts ingredients with quantities and preparation notes
- [ ] Each parsed ingredient is resolved against the database or added with appropriate provenance
- [ ] Role inference is performed against the locked 36-role list and the inferred role is included in output
- [ ] Substitution candidates come from the database first, LLM second
- [ ] Cost context is included for ingredients that have market_prices data
- [ ] Output includes provenance signals (which content is verified vs inferred)
- [ ] Engine writes to `user_corrections` when given correction input
- [ ] Engine works on at least 3 test recipes spanning complexity tiers

Owner: Lee, in Claude Code.

Target: Tuesday and Wednesday.

## Milestone 5: Front-end and Deployment

Definition of done:
- [ ] Single-page web interface with recipe input, region selector, mode toggle, analyze button, and results display
- [ ] Loading state during analysis
- [ ] Output rendering matches v1 spec (recipe summary with roles, market context, substitutions with reasoning, verdict)
- [ ] User can click a role to flag it as wrong, this writes to user_corrections
- [ ] Mobile-responsive enough that it does not look broken on a phone
- [ ] Deployed to a public URL
- [ ] Supabase credentials live in environment variables, not in client-side code
- [ ] Anonymous user sessions tracked for correction capture

Owner: Lee, in Claude Code.

Target: Thursday.

## Milestone 6: Smoke test and demo readiness

Definition of done:
- [ ] At least 5 real-world recipes processed end-to-end without errors
- [ ] Output is good enough that Lee would show it to a Toast interviewer without apology
- [ ] Demo script written for the Toast interview
- [ ] Public URL accessible from any browser
- [ ] Basic error tracking in place (logs are reviewable somewhere)

Owner: Lee.

Target: Friday.

## Cut line discipline

If at the end of any day a milestone is significantly behind, scope gets cut, not extended. The week ends Friday regardless. The cuts are documented in `docs/spec-v1.md` under "Cut line for the week."

## Deferred (post-v1)

These items existed in the original Milestone 1 list but are explicitly deferred. They live in the schema (tables exist, empty) but are not used by the v1 engine. Build them when their dependent features are built.

- Dish archetypes seed (5+ archetypes; powers cross-cultural translation)
- Cooking methods and equipment seed (10+ each; powers technique-aware substitution)
- Techniques and sensory doneness cues (powers wok-hei-style technique reasoning)
- Adjustment guidance (8+ rows; powers "your dish is too salty, here is what to do")
- Catch-all monitoring view (migration 0004; surfaces patterns for role taxonomy growth)
- Periodic catch-all report mechanism (Lee requested robust feedback reporting)
