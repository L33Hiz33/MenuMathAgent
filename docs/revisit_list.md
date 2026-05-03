# Revisit List

Living document. Open concerns, deferred work, and real architecture decisions to come back to. Reformed May 2 to add Engine A/B/C structure and output styling.

**Last updated:** 2026-05-02 (post-deploy)

---

## TONIGHT remainder

1. **Test live site end-to-end on menumathagent.com.** Cache hit, cache miss, full engine run on production URL. Real concern: CORS may block requests from new domain.

2. **Lock CORS on Edge Functions.** Currently `Access-Control-Allow-Origin: *`. Lock to `menumathagent.com` only. Real safety.

3. **Rotate Anthropic API key.** Was exposed in chat memory earlier today (see CLAUDE.md key safety rule). Real safety. Update Supabase secrets, GitHub Actions secrets, and `.env.local` after rotation.

---

## ENGINE A (canonical seeding via claude.ai Opus)

4. **Seed more dishes.** Currently 8 dishes total. Real Toast demo wants 20-30 minimum for "any dish I ask" coverage. Real candidate list: poutine, lasagna, jambalaya, gumbo, pho, tonkotsu variants beyond Hakata, croissant, bibimbap, mole, paella, falafel, shakshuka, biryani, dim sum staples, dumplings, more.

5. **Cuisine coverage gap.** Currently 7 cuisines. Real Toast risk: interviewer asks Filipino, Ethiopian, Peruvian, Korean (non-bibimbap), Japanese (non-ramen). Need broader spread.

6. **Sub-recipe seeding validation.** Engine A output includes sub-recipes (dough, sauces, pickles, pastes). Validate these are parsed into `recipe_sub_recipes` correctly and not flattened into parent recipes.

---

## ENGINE B (decomposition — current, deployed v1.2)

Engine B status: deployed via async pipeline, Sonnet 4.5, prompt in DB, ~215s typical, validated on Croque Madame, Turtle Soup, Tacos al Pastor. Items below are open work.

### SQL execution path (Phase 4d / Phase 6)

7. **SQL extraction from markdown wrapper.** Engine output is markdown wrapping a SQL block in code fences. Need parser to extract just the SQL. Output ends with `**END OF DECOMPOSITION**` not `COMMIT;`.

8. **Forbidden-keyword regex scoped to SQL block only.** Currently scans whole output. Real risk: narrative could mention "this is NOT a DROP TABLE pattern" and trip filter. Move check to extracted SQL only.

9. **Old truncated turtle soup row needs skip-on-execute.** Row id `5dd01e81-ccf6-43c0-8d5a-5578f91bdac7`. Marked failed retroactively. Add explicit safeguard: only execute rows where `status='complete' AND executed IS NOT TRUE`. Add `executed BOOLEAN` column to decompose_jobs.

10. **SQL execution architecture decision.** Two real paths:
    - Option 1: run SQL directly (chosen at Phase 4c with PoC scope, accept injection risk)
    - Option 2: parse SQL into structured inserts via Supabase client (safer, more code)
    Decision deferred. Revisit when wiring execution.

11. **Pre-call retrieval.** Before calling Anthropic, query existing rows from `cuisines`, `ingredients`, `techniques`, `equipment`, `cooking_methods`, `ingredient_categories`. Inject summary so engine matches existing rows by name. Real benefit: cleaner `proposed_rows`, fewer dedup issues.

12. **Post-output dedup logic.** Even with pre-call retrieval, engine may propose semantically duplicate rows. FK-aware dedup pass before INSERT. If proposed name matches existing by case-insensitive comparison, skip insert and link recipe to existing id.

### Engine B quality (post-Toast)

13. **RAG refactor of v1.2 prompt.** Prompt has dish-specific learnings inline (banh mi mayo, carnitas manteca). Real scaling wall: prompt grows per dish learned. Four solution patterns: retrieval table with similarity match, cuisine-categorized learnings, abstracted principles, layered prompt. Lean retrieval. Don't refactor before Toast.

14. **Substitution classification enum.** Migration 0006 added the enum but output uses `notes` field. Parse classification from output, write to `substitution_classification` column for queryable filtering.

15. **dish_variants table.** Engine flags dish variants (glass noodles → pad woon sen, no egg → croque monsieur) in narrative but they don't land anywhere. Create `dish_relationships` table, parse, seed.

16. **Self-evaluation correlated blind spots.** Same-model self-eval has known limits. Real long-term mitigation: human expert review pipeline that promotes provenance `llm_inferred_low_confidence` → `human_verified_expert`.

---

## ENGINE C (forecasting + financial — NOT BUILT YET)

Real architecture not yet scoped. Engine C is the missing layer that turns Engine B's decomposition into "this week's actual market context plus near-term forecast."

17. **Engine C scope decision.** Two real paths:
    - C1: real-time market data layer. Pulls USDA AMS, BLS food CPI, USDA ERS feeds. Joins to Engine B output. Returns "this week, beef up 4%, dairy down 2%."
    - C2: historical pattern + seasonality only. No live feed. Pattern-based projections.
    Lean C1 for Toast story. C2 is faster to ship. Real call needed before any code.

18. **Engine C input shape.** Takes Engine B output (decomposed dish) + region + month. Returns forecast bands per ingredient. Real concern: input could be 44k chars; need extraction strategy.

19. **Engine C output shape.** Real concern: another markdown blob, or structured JSON? Lean structured JSON. Engine C output goes into UI tables and charts, not narrative panels.

20. **Engine C model choice.** Sonnet 4.5 vs Haiku. Forecasting reasoning lighter than decomposition. Haiku may suffice. Real cost matters since it hits per-dish-view, not per-decomposition.

21. **Data sources for Engine C.** USDA AMS, BLS food CPI, USDA ERS outlook (per original CLAUDE.md spec). Real concern: public APIs that need pull-and-cache layer or live calls. Rate limits, schema, freshness all unknown.

22. **Pre-call retrieval for Engine C.** Fetch Engine B's decomposition rows + market data context. Inject as input.

23. **Engine C async pipeline.** Same pattern as Engine B (GitHub Actions worker). Real new table: `forecast_jobs`. Real new Edge Functions: `submit-forecast`, `check-forecast`. Or extend existing pattern with `engine` column on jobs table.

---

## OUTPUT FORMAT / STYLING (real iteration work)

24. **Result panel currently dumps 44k char markdown into `<pre>` block.** Real ugly. No structure visible. Real Toast demo concern.

25. **Parse Engine B output into structured UI sections:**
    - Iteration narrative (collapsed by default)
    - Substitutions table (sortable by quality_match_score, cost_direction)
    - Anti-patterns callout (red/warning style)
    - Dish variants list
    - Regional/seasonal context box
    - Final SQL (collapsed for devs only)

26. **Engine C forecasts go into separate panel with charts.** Recharts or Chart.js. Real concern: chart library bundle size on landing page.

27. **Mobile responsiveness pass.** Editorial design currently desktop-only. Real demo risk: Toast interviewer pulls phone.

28. **Print/PDF export.** Real food truck operator may want printable substitution sheet for kitchen wall.

29. **Cache hit panel currently shows only dish name + description.** Real fix: show full Engine B + Engine C output for cached dishes too. Currently cache hit feels less useful than cache miss.

---

## CACHE LOGIC (Phase 6+)

30. **Cache normalization.** Typo, plural, article, cuisine prefix. Cases observed:
    - "bahn mi" vs "banh mi"
    - "tacos al pastor" vs "taco al pastor"
    - "the carbonara" vs "carbonara"
    - "vietnamese banh mi" vs "banh mi"
    - "spaghetti carbonara" vs "carbonara"

    Solution patterns:
    - A. PostgreSQL `pg_trgm` trigram similarity
    - B. Haiku pre-flight normalizer (~$0.001/call, ~1 sec)
    - C. Suggest-match dropdown as user types
    - D. Hardcoded alias table
    - E. Combine B + C

    Lean E. Don't refactor before Engine C lands.

31. **Cache key scope.** Currently dish-name-only. Engine output is region-and-season-aware per v1.2. Decision: per-dish cache for v1 demo, per-(dish, region, season) cache for production.

---

## DEPLOY HARDENING (Phase 8+)

32. **CORS lockdown to menumathagent.com.** Same as item 2.

33. **Rate limiting on submit-job.** Anyone with anon key can trigger $0.30 GitHub Action runs. Per-IP limit or auth gate.

34. **/test-db page.** Exposes raw DB JSON. Harmless content but unprofessional. Delete for prod, gate behind auth, or block via robots.txt.

---

## INFRASTRUCTURE

35. **Node.js 20 deprecation in GitHub Actions.** Warning on every run. Fix before September 2026. Bump `actions/checkout@v4` or set `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true`.

36. **GitHub Actions cold start UX.** 30-60 sec to first response. Pre-warm with noop run before demo, or add UX message ("starting compute environment...").

37. **Supabase service_role key rotation.** Live in GitHub Actions secrets. Rotate every 90 days. Calendar reminder needed.

---

## Done / closed

- May 2: Migration 0009 (decompose_jobs table)
- May 2: GitHub Actions worker (PowerShell, ubuntu-latest)
- May 2: submit-job Edge Function
- May 2: check-job Edge Function
- May 2: Worker hardening (32k token ceiling + truncation detection)
- May 2: RecipeForm.tsx wired to async pipeline (state machine, polling, four result panels)
- May 2: Vercel deploy, custom domain menumathagent.com