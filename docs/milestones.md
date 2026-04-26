# Milestones

Each milestone has a definition of done. A milestone is not complete until every item under "definition of done" is true and demonstrated.

## Milestone 0: Foundation (DONE)

Definition of done:
- [x] Repo created at `C:\Users\hisey\recipe-advisor\`
- [x] Git initialized, initial commit made
- [x] Documentation scaffold in place (README, CLAUDE.md, docs/, ADR stubs)
- [x] Supabase project created
- [x] Database schema deployed (27 tables, all FKs, indexes, triggers)
- [x] Product brief and v1 spec written

Completed: Saturday evening.

## Milestone 1: Curated Seed Content

Definition of done:
- [ ] Role taxonomy populated (15 to 20 ingredient roles, with descriptions)
- [ ] At least 5 cuisines populated
- [ ] At least 25 ingredients populated with category, role-relevant flavor attributes, and at least one alias each where appropriate
- [ ] At least 5 dishes populated with archetype links and ingredient role requirements
- [ ] At least 30 substitution rows populated, each with role context and cost direction
- [ ] At least 5 dish archetypes populated
- [ ] At least 10 cooking methods and 10 equipment rows populated
- [ ] At least 5 techniques populated, with at least 1 sensory cue each
- [ ] At least 8 adjustment_guidance rows (covering each flavor dimension and direction)
- [ ] All seed content has appropriate provenance markers (most are `human_verified_expert` or `human_submitted_unverified`)

Owner: Lee, with assistance from Ingredient Knowledge Agent.

Target: end of Sunday.

## Milestone 2: Ingredient Knowledge Agent (skeleton)

Definition of done:
- [ ] Script (Node or Python) connects to Supabase using service role credentials from environment variables (not hardcoded)
- [ ] Given a dish name, agent generates candidate ingredient rows with `llm_inferred_low_confidence` provenance
- [ ] Generated rows include suggested role assignments and substitution candidates
- [ ] Lee can review candidates in the database (via Supabase Table Editor) and promote to verified
- [ ] Agent does not generate duplicate rows for ingredients that already exist (uses canonical_name and aliases for matching)

Owner: Lee, in Claude Code.

Target: Sunday.

## Milestone 3: Market Data Agent (USDA terminal market)

Definition of done:
- [ ] Script fetches current USDA AMS terminal market report for at least one region (Dallas or Atlanta)
- [ ] Parser converts the report into structured rows for `market_prices`
- [ ] At least 10 to 15 of the seeded ingredients have a current price row in their region
- [ ] `market_data_sources` has the source registered with last_fetched_at populated
- [ ] Script can be re-run safely (idempotent for the same date)
- [ ] Errors and parsing failures are logged, not silent

Owner: Lee, in Claude Code.

Target: Monday.

## Milestone 4: Recipe Reasoning Engine

Definition of done:
- [ ] Given a recipe text and region, engine returns structured output matching the v1 spec
- [ ] Recipe parser extracts ingredients with quantities and preparation notes
- [ ] Each parsed ingredient is resolved against the database or added with appropriate provenance
- [ ] Role inference is performed and the inferred role is included in output
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
