# Risks and Unknowns

Living document. Updated weekly or whenever something material changes.

## Open risks

### USDA terminal market report parsing
The USDA AMS terminal market reports are messy. Format varies by region and commodity. Historical scraping work suggests the parser will break on edge cases. If parsing takes much longer than estimated Monday, the fallback is to manually pull a sample of prices for 10 to 15 ingredients and use that as v1 market data, with the parser deferred to v1.1.

### LLM cost and latency
Each recipe analysis involves multiple LLM calls (parsing, role inference, substitution reasoning, output generation). At Claude Sonnet 4.6 or comparable rates, each request might cost a meaningful fraction of a cent. Per-user cost is fine. Per-demo cost is fine. Watch for runaway costs if a recipe triggers many retries.

### Supabase free tier limits
Free tier is generous but not unlimited. Database size is unlikely to be a constraint at v1 scale. Bandwidth from data fetches could be a concern if the Market Data Agent runs frequently. Monitor via Supabase dashboard. Upgrade to Pro tier if needed (~25 USD/month).

### Scope discipline
The biggest risk in this project is scope expansion mid-week. The cut line in spec-v1.md is the discipline. If Wednesday end-of-day shows the runtime is not working end-to-end, scope cuts apply automatically. Do not negotiate with the deadline.

### Deployment friction
The first deploy is always the hardest. Vercel for the front end is straightforward. The reasoning engine probably wants a serverless function or a small backend. Connecting a backend to Supabase from a public URL has security considerations (do not expose service role key). Allocate Thursday for this even if it seems excessive.

### LLM hallucination in substitutions
The LLM will sometimes suggest substitutions that are wrong (wrong role, regionally unavailable, technically infeasible). The mitigation is provenance discipline plus user_corrections capture, not preventing it upfront. Be honest about confidence in the UI.

### Pastry roles unvalidated against a real pastry dish
The pastry roles (`dough_structure`, `structural_fat`, `flavor_fat`, `leavener`) were locked in migration 0002 but no actual pastry dish was walked end-to-end as part of the role lock stress tests. Stress tests covered gumbo, banh mi, Wellington, margherita, turducken, Thai green curry, and mole poblano. None of these are pastry-forward. Risk: when a real pastry-heavy dish is seeded (croissant, tarte tatin, anything with serious bake science), the pastry roles may need revision via migration 0005+. Mitigation: walk one pastry dish before seeding multiple pastry items. Catch-all role (`other_component`) and pattern review will surface promotion candidates.

### Engine prompt quality (new, April 29)
The runtime LLM research engine (B in the A+B architecture) is only as good as its prompt. The prompt has to consistently:
- Assign roles from the locked 36-role list, not invent new ones
- Recognize when a slot needs a sub-recipe versus a single ingredient
- Use the catch-all (`other_component`) sparingly, only when no real role fits
- Maintain provenance discipline on every row written

If the prompt drifts under load or across cuisines, data fragments. Mitigation: prompt design happens in claude.ai chat (not Claude Code) where iterative refinement and human review of output samples is easiest. Engine output is reviewed by a human before any database write during seed phase. At runtime, all new rows are marked `llm_inferred_low_confidence` until reviewed.

### Substitutions table has no unique constraint (new, April 29)
`substitutions` has no unique constraint on `(original_ingredient_id, substitute_ingredient_id, role_id, substitution_purpose)`. The same substitution can be inserted multiple times. Application logic must dedupe before insert. Schema fix deferred (would be a future migration). Risk: if seed engine writes duplicates, substitution engine returns duplicate suggestions to user.

### Ingredient_aliases.alias_name is not unique (new, April 29)
The alias name field is indexed for query performance but has no unique constraint. The same alias name could map to two different canonical ingredients. Recipe parser would have ambiguous resolution. Schema fix deferred.

### Documentation drift (new, April 29)
The April 29 reconciliation revealed that disk docs and claude.ai Project Knowledge had drifted from each other and from the database state. Reconciled on April 29 (disk = single source of truth). Risk: future drift if status.md and CLAUDE.md are not updated each session. Mitigation: update at end of each session per the discipline already in CLAUDE.md.

## Resolved risks

### Recipes cannot reference other recipes as sub-recipes (resolved 2026-04-27)
Resolved by migration 0003 (`recipe_sub_recipes` table). Recipes can now reference other recipes as components with role context, quantity, unit, step order, and notes. Cycle prevention enforced by application code (CHECK constraint cannot catch multi-hop cycles).

### No model for dish pairings (resolved 2026-04-27)
Resolved by migration 0003 (`dish_pairings` table). Companion dishes can be linked with `contrast_dimensions` array, `synergy_notes`, and `popularity_tier` (universal, regional, insider_knowledge, innovative).

### Role taxonomy unlocked (resolved 2026-04-29)
Resolved by migration 0002 (role taxonomy seed, 36 roles). Locked through stress-testing against 7 dishes spanning multiple cuisines. Slot-based framework adopted: roles are SLOTS named by FUNCTION; sub-recipes fill slots; substitutions are alternative slot-fillers. Catch-all role (`other_component`) handles edge cases with required notes; pattern-review monitoring view planned for migration 0004.

## Unknowns

### What food truck operators actually want from a tool like this
We have hypothesized but not validated. Closest thing to validation is Lee's domain knowledge from cooking seriously and conversations with operators. Real usage data from 5 to 10 operators in the 30-day window will be the first real signal.

### How accurate the LLM is at role inference across cuisines
Likely good for Western and East Asian cuisines, less reliable for cuisines underrepresented in training data. The user_corrections table will surface where it fails. v1 ships with the assumption that 70 to 80 percent accuracy on role inference is sufficient.

### How well the cross-cultural archetype feature lands
This is a differentiated feature but may be too clever. If Toast interviewers find it gimmicky, the feature is dead weight in the demo. Watch for reactions. Note: `dish_archetypes` and `dish_archetype_components` tables exist but are empty in v1; archetype-driven cross-cultural reasoning is post-v1.

### Right pricing model long-term
v1 is free. v1.1 might add a paid tier (invoice ingestion, menu planning). The right price point and packaging is unknown. Not a v1 problem.

### Whether the role list converges or keeps growing
The first stress test exposed gaps. The seventh (mole poblano) confirmed coverage but raised the multi-function ingredient question (chipotle = umami + heat + smoke; Mexican chocolate = umami + fat + sweet + spice). Resolved with primary role + notes pattern. At some point real users hitting unexpected dishes will keep finding edge cases. The bet is that the catch-all monitoring view (migration 0004, pending) and user_corrections together catch these and grow the role list organically. If they do not, the role list will need periodic curated review.

## Bets we are making

### Public market data is sufficient for useful output
We are betting that USDA terminal markets, BLS CPI, USDA ERS, and seasonality data together give enough signal for substitution recommendations to be worth a food truck operator's time. If the data turns out to be too coarse, the value prop weakens significantly.

### Provenance discipline solves the LLM trust problem
We are betting that being transparent about what is verified vs inferred lets us ship LLM-generated content without it being a liability. If users do not understand or care about provenance, this complexity is overhead.

### Food truck operator is a defensible v1 wedge
We are betting this user is reachable, has a real problem, and is interesting enough to demo to Toast. If Toast's actual interest is in higher-volume restaurants with full POS integration, the food truck framing might be a miss.

### One week is enough to ship a viable demo
Tight but real with 24 focused hours. Risk is highest if the USDA parser or deployment hits unexpected friction.

### Stress-testing seven dishes is enough role list validation
We are betting that gumbo, Wellington, banh mi, pizza, turducken, Thai green curry, and mole poblano collectively cover enough structural variety that the v1 role list (36 roles) is good enough. If real usage exposes 5+ more roles needed in the first month, we may need to do another structured stress-test pass. Catch-all monitoring is the early warning system.

### Slot-based role framework holds across cuisines
We are betting that naming roles by their FUNCTION in the parent recipe (rather than by what they physically are) generalizes across cuisines. Pickle_component fills the same slot whether the pickle is Vietnamese, German, or Korean. If a cuisine has structural patterns the slot framework misses, the catch-all view will surface it.
