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

### Schema gaps from stress testing (Saturday evening)

Stress-testing the role list against five real dishes (gumbo, Wellington, banh mi, pizza, turducken) exposed two real schema gaps that need to be fixed before substantial seed content is created:

1. **Recipes cannot reference other recipes as sub-recipes.** Most non-trivial recipes use sub-recipes (sauces, stocks, dressings, pastry creams, duxelles, etc.). The `recipe_ingredients` table only links to `ingredients`, not to other `recipes`. Migration 0003 will add a `recipe_sub_recipes` join table.

2. **No model for dish pairings.** Companion dishes served alongside a primary dish (potato salad on gumbo, crema on tinga, naan with dal). Migration 0003 will add a `dish_pairings` table with metadata for contrast dimensions, synergy notes, and popularity tier.

Both gaps are scheduled to be addressed first thing Sunday morning. Risk: if these are deferred and substantial seed content is created without them, the seed will need rework.

### Pastry roles unvalidated against a real pastry dish
The pastry roles (structural_flour, lamination_fat, tenderizing_fat, etc.) were added during the stress test conversation but no actual pastry dish was walked end-to-end. Risk: when a real pastry dish is seeded (croissant, tarte tatin, anything with serious bake science), the pastry roles may need revision. Mitigation: walk one pastry dish before seeding multiple pastry items.

## Unknowns

### What food truck operators actually want from a tool like this
We have hypothesized but not validated. Closest thing to validation is Lee's domain knowledge from cooking seriously and conversations with operators. Real usage data from 5 to 10 operators in the 30-day window will be the first real signal.

### How accurate the LLM is at role inference across cuisines
Likely good for Western and East Asian cuisines, less reliable for cuisines underrepresented in training data. The user_corrections table will surface where it fails. v1 ships with the assumption that 70 to 80 percent accuracy on role inference is sufficient.

### How well the cross-cultural archetype feature lands
This is a differentiated feature but may be too clever. If Toast interviewers find it gimmicky, the feature is dead weight in the demo. Watch for reactions.

### Right pricing model long-term
v1 is free. v1.1 might add a paid tier (invoice ingestion, menu planning). The right price point and packaging is unknown. Not a v1 problem.

### Whether the role list converges or keeps growing
The first stress test exposed gaps. The fifth still exposed one (turducken's nested protein layers and stuffing-as-interstitial-layer). At some point real users hitting unexpected dishes will keep finding edge cases. The bet is that the user_corrections table catches these and grows the role list organically. If it does not, the role list will need periodic curated review.

## Bets we are making

### Public market data is sufficient for useful output
We are betting that USDA terminal markets, BLS CPI, USDA ERS, and seasonality data together give enough signal for substitution recommendations to be worth a food truck operator's time. If the data turns out to be too coarse, the value prop weakens significantly.

### Provenance discipline solves the LLM trust problem
We are betting that being transparent about what is verified vs inferred lets us ship LLM-generated content without it being a liability. If users do not understand or care about provenance, this complexity is overhead.

### Food truck operator is a defensible v1 wedge
We are betting this user is reachable, has a real problem, and is interesting enough to demo to Toast. If Toast's actual interest is in higher-volume restaurants with full POS integration, the food truck framing might be a miss.

### One week is enough to ship a viable demo
Tight but real with 24 focused hours. Risk is highest if the USDA parser or deployment hits unexpected friction.

### Stress-testing five dishes is enough role list validation
We are betting that gumbo, Wellington, banh mi, pizza, and turducken collectively cover enough structural variety that the v1 role list is good enough. If real usage exposes 5+ more roles needed in the first month, we may need to do another structured stress-test pass.

## Resolved risks

(Move risks here when they no longer apply, with a note on how they were resolved.)

(none yet)
