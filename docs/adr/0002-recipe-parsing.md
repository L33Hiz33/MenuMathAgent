# ADR 0002: Recipe Parsing Approach

Status: Accepted
Date: April 2026

## Context

The user pastes a freeform recipe. We need to extract ingredients, quantities, units, preparation notes, and ideally identify the dish. The recipe could be:

- A copied web page with markup artifacts
- A bulleted ingredient list with no instructions
- Prose from a memory ("a pinch of salt and a glug of olive oil")
- Structured JSON if a power user is feeding us data
- Multilingual or with regional ingredient names

A traditional NLP parser would require extensive training data and brittle rules. An LLM handles all of these inputs reasonably well out of the box.

## Decision

Use the LLM for recipe parsing. Specifically:

1. The recipe text is sent to the LLM with a structured-output prompt asking for: ingredients (name, quantity, unit, preparation, optional flag), instructions (if present), inferred dish name, and a confidence indicator per parsed ingredient.

2. The LLM returns JSON conforming to a schema. We validate the JSON shape, not the content.

3. Each parsed ingredient is then resolved against the `ingredients` table:
   - Try canonical_name match first
   - Then try `ingredient_aliases` for the alias_name
   - If no match, the LLM provides a candidate canonical_name and the row is added with `llm_inferred_low_confidence` provenance for later review

4. Role inference is a separate LLM call after parsing, with the full recipe context. Role is per `recipe_ingredient`, not per ingredient.

5. The dish identification is best-effort. If the LLM identifies a dish that matches a row in `dishes`, link it. If not, treat as a standalone recipe.

## Consequences

**Positive:**
- Handles every recipe format we will realistically see
- Cost is small (~1 LLM call per parse, plus 1 for role inference)
- Improves automatically as the underlying model improves
- Schema (with `inference_source` column on `recipe_ingredients`) tracks how each ingredient was identified

**Negative:**
- LLM hallucinations in parsing are possible. A "wrong" quantity or unit is a real risk.
- Latency is real (1 to 3 seconds per call).
- Cost scales linearly with usage.

**Mitigation:**
- Show the parsed result to the user with a "fix this" affordance. Capture corrections.
- The role inference is a sanity check on the parse. If the role does not make sense for the parsed ingredient, the parse was wrong and we re-parse.
- Cache parses for identical input text.

## Alternatives considered

**Rule-based parser.** Rejected. Too brittle, would require a meaningful upfront engineering effort, would still need an LLM fallback for unusual cases.

**Off-the-shelf recipe parser library.** Considered. Some exist (Ingreedy, Microsoft's recipe NLP). They are okay but not better than an LLM with a good prompt, and they are more rigid.

**Two-stage parse.** First a structural parse (find the ingredient list), then a per-ingredient parse. Considered. May be worth doing later for cost optimization. v1 uses single-call parsing for simplicity.
