# v1 Behavior Spec

This document describes what the v1 product does, in terms a developer or designer can implement against. It is not a UI mockup. It is the behavior contract.

## User flow

1. User lands on the website. Sees a single screen with a recipe input field and a region selector.
2. User pastes a freeform recipe (ingredient list and instructions, or just ingredients) into the input.
3. User selects their state from a dropdown. Optionally selects a metro area.
4. User clicks "Analyze recipe."
5. Tool processes (5 to 15 seconds expected, with a loading state).
6. Tool displays results.

## Inputs

- **Recipe text:** freeform, up to ~5,000 characters. The tool handles inconsistent formatting, missing measurements, vague quantities ("a pinch", "to taste"), regional ingredient names, and recipes with or without instructions.
- **Region:** US state (required), metro (optional). Used for terminal market mapping and regional availability.
- **Mode flag (default cost reduction):** the tool defaults to suggesting cheaper substitutions. A toggle allows "quality improvement" mode where the tool suggests upgrades.

## Processing

The tool performs the following work per request:

1. **Recipe parsing.** Extract ingredients with quantities, units, and preparation notes from the freeform text. Use the LLM. Capture inference confidence per ingredient.

2. **Ingredient resolution.** Map each parsed ingredient to a row in the `ingredients` table, using `ingredient_aliases` for non-canonical names. If no match, the LLM provides a candidate and the row is added with `llm_inferred_low_confidence` provenance.

3. **Role inference.** For each ingredient, infer its role in this specific recipe (structural aromatic base, primary protein, etc.). The LLM does this with the recipe context. The inferred role is shown to the user.

4. **Dish identification (best effort).** If the recipe matches a known dish, link it. If not, treat as standalone.

5. **Market context.** For each ingredient, query `market_prices` for the user's region and the most recent date. Pull seasonality from `seasonality_patterns`. Surface notable signals (much above or below historical norm, in or out of peak season).

6. **Substitution generation.** For each ingredient, query `substitutions` table filtered by role, cuisine (if known), and substitution_purpose matching the user's mode (cost_reduction by default). If fewer than 3 candidates exist for an ingredient, use the LLM to generate additional candidates and write them to the database with `llm_inferred_low_confidence` provenance for later review.

7. **Substitution scoring.** Rank substitutions by cost direction, quality match score, and regional availability.

8. **Reasoning generation.** For each substitution recommendation, generate a short human-readable explanation that includes role match, cost direction, technique notes if any, and any regional availability concerns.

## Outputs

The result page contains:

- **Recipe summary.** The recipe as parsed, with each ingredient shown next to its inferred role. The user can click a role to flag it as wrong (this writes to `user_corrections`).
- **Market context.** A short section noting overall cost signals for this recipe right now. "Beef chuck is up 11% YoY. Cilantro is in peak season in your region."
- **Substitution recommendations.** Per ingredient where worthwhile, a short list of 1 to 3 substitution candidates with reasoning. Each candidate shows: substitute name, cost direction, role fidelity, technique adjustment notes if any, regional availability flag if any.
- **Honest verdict.** A one-sentence assessment: "Good week to make this dish" or "This dish is expensive right now, here is the cheapest viable variant."

## What the output is grounded in

Every cost claim cites its source (USDA terminal market, BLS, USDA ERS, or "based on historical pattern"). The UI shows the source link or label inline. No price is asserted without a source.

Substitutions show their provenance lightly. A substitution from `human_verified_expert` is presented with confidence. A substitution from `llm_inferred_low_confidence` is labeled "AI-suggested, not yet reviewed."

## Error handling

- If the recipe cannot be parsed, the tool says so and asks the user to clarify.
- If no market data is available for the user's region for an ingredient, the tool says "no current pricing available, suggesting based on historical patterns" rather than fabricating.
- If the LLM call fails, the tool falls back to whatever can be served from the database alone (curated substitutions, seasonality).

## Performance

- Total response time target: under 15 seconds for a typical recipe.
- LLM calls are minimized by querying the database first.
- Caching of ingredient resolutions is acceptable.

## Capture for learning

Every recipe submitted is logged. Every substitution shown is logged. Every user correction is captured. This data feeds the curated layer over time.

## Out of scope for v1

- Saving recipes
- User accounts
- Sharing or social features
- Mobile app (responsive web is fine)
- Multi-language UI
- Advanced filters (vegetarian, halal, etc.) beyond what falls naturally out of substitution_purpose

## Cut line for the week

If by Wednesday end-of-day the recipe parsing, role inference, and substitution generation are not working end-to-end on three test recipes, scope is cut. Likely cut targets in priority order:

1. Cross-cultural dish translation (drop entirely from v1, defer)
2. Technique-aware substitution (drop the technique layer from v1 reasoning, keep schema)
3. Fancy UI (use the simplest possible interface)
4. Multiple substitution candidates per ingredient (cap at 1 per ingredient)
5. Market context narrative (use a simpler output format)

The recipe parser, role inference, and substitution-with-reasoning core do not get cut. Without those, there is no product.
