# Revisit List

Living document. Open concerns, deferred work, and real architecture decisions to come back to. Updated as we move through phases.

**Last updated:** 2026-05-02

---

## Phase 4d / Phase 6: SQL execution

These block when we wire engine output into the DB.

1. **SQL extraction from markdown wrapper.** Engine output is markdown (narrative + iteration scores) wrapping a SQL block in code fences. Need a real parser to extract the SQL block before execution. Turtle soup output ends with `**END OF DECOMPOSITION**`, not `COMMIT;`.

2. **Forbidden-keyword regex false positives.** `submit-job` Edge Function scans whole output for `DROP TABLE` etc. Real risk: engine narrative could mention "this is NOT a DROP TABLE pattern" and trip the filter. Move keyword check to scan only the extracted SQL block, not the whole response.

3. **Old truncated turtle soup row needs skip-on-execute.** Row id `5dd01e81-ccf6-43c0-8d5a-5578f91bdac7` has partial SQL with no COMMIT. Marked failed retroactively (good). When SQL execution lands, add explicit safeguard: only execute rows where `status='complete' AND executed IS NOT TRUE`. Add `executed BOOLEAN` column to decompose_jobs.

4. **SQL execution architecture decision.** Two real paths still on the table:
   - Option 1: run SQL directly (chosen at end of Phase 4c with PoC scope, accept injection risk)
   - Option 2: parse SQL into structured inserts, use Supabase client (safer, much more code)
   Decision deferred. Revisit when we actually wire execution.

5. **Pre-call retrieval (NEW from May 2 conversation).** Before calling Anthropic, query existing rows from `cuisines`, `ingredients`, `techniques`, `equipment`, `cooking_methods`, `ingredient_categories` tables. Inject summary into the user message so engine matches existing rows by name instead of proposing duplicates. Real benefit: cleaner `proposed_rows` lists, fewer dedup issues downstream.

6. **Post-output dedup logic (NEW from May 2 conversation).** Even with pre-call retrieval, engine may propose rows that semantically duplicate existing ones (e.g. "italian" vs "italian cuisine"). Real fix: FK-aware dedup pass before INSERT. If `proposed_rows.cuisines.name` matches existing row by case-insensitive normalized comparison, skip insert and link recipe to existing id.

---

## Phase 5: frontend wiring

7. **Replace alert() in RecipeForm.tsx.** Currently form submit shows alert with input data. Real fix: fetch to `/functions/v1/submit-job`, show loading spinner, kick polling.

8. **Build polling logic.** Frontend hits `check-job` Edge Function every 5 sec until status is `complete` or `failed`. Show progress messages while running. Real concern: polling for 4+ minutes will burn user attention; consider streaming progress messages or estimated-time-remaining UI.

---

## Phase 6: cache logic

9. **Cache lookup is prefix match.** `ilike "${dishLower}%"` in submit-job. "tonkotsu ramen" matches cached "tonkotsu" (good) but cached "tonkotsu ramen" doesn't match query "tonkotsu" (bad). Refine: full-text search, fuzzy match, or canonical name normalization.

10. **Cache key scope.** Currently dish-name-only. Real question: should cache miss when same dish is queried for different region or month? Engine output is region-and-season-aware per v1.2 prompt. Decision: per-dish cache for v1 demo, per-(dish, region, season) cache for production.

---

## Phase 8: deploy / production

11. **CORS lockdown.** `submit-job` and other Edge Functions allow `Access-Control-Allow-Origin: *`. Real for production: restrict to menumathagent.com.

12. **No rate limiting.** Anyone with the anon key can hit `submit-job` and trigger $0.30 GitHub Action runs. Real abuse vector. Add per-IP rate limit or auth gate before public launch.

13. **`/test-db` page exposes raw DB JSON.** Harmless data (8 dish names) but unprofessional public face. Real options: delete the route before public deploy, gate behind auth, or block via robots.txt.

---

## Engine / prompt architecture (post-Toast)

14. **RAG refactor of v1.2 prompt.** Current prompt has dish-specific learnings inline (banh mi mayo, carnitas manteca, etc). Real scaling wall: prompt grows with each new lesson learned. Four solution patterns identified (retrieval table with similarity match, cuisine-categorized learnings, abstracted principles, layered prompt). Plan: refactor at v1.5 or v2.0. User leans toward retrieval pattern. Don't refactor before Toast demo.

15. **Substitution classification enum.** Migration 0006 added the enum but engine output uses `notes` field for now. Real cleanup: parse the classification from engine output and write to `substitution_classification` column for queryable filtering.

16. **`dish_variants` section not yet structured.** Engine output flags dish variants (glass noodles → pad woon sen, no egg → croque monsieur) but these don't land in any table. Real future work: create `dish_relationships` table, parse and seed.

17. **Self-evaluation correlated blind spots.** Per v1.2 prompt notes, same-model self-eval has known limits. Real long-term mitigation: human expert review pipeline that promotes provenance from `llm_inferred_low_confidence` to `human_verified_expert`.

---

## Infrastructure

18. **Node.js 20 deprecation in GitHub Actions.** Warning shows on every Action run. Real fix before September 2026: bump `actions/checkout@v4` and add `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true` env var, or wait for v5 of those actions.

19. **GitHub Actions cold start adds 30-60 sec to demo latency.** Real demo concern: first dish click after idle period feels slow. Mitigation: pre-warm with a noop run before demo, or accept the latency and add UX explanation ("starting compute environment...").

20. **Supabase service_role key in GitHub Actions secret.** Real safety: rotate periodically. Set a calendar reminder for every 90 days. If repo ever leaks, this key has full DB write access and must be rotated immediately.

---

## Done / closed

(none yet — list will grow as items get resolved)