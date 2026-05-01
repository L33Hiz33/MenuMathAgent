-- ============================================================
-- Backfill: substitution_classification for pre-v1.2 rows
--
-- 57 NULL rows from earlier seeds (banh mi, tonkotsu, margherita,
-- cheeseburger, carnitas) classified per Engine B v1.2 framework.
--
-- Distribution:
--   real_substitution: 49 rows (valid swaps within dish identity)
--   anti_pattern: 6 rows (errors with explicit warning notes; quality_score <= 0.30)
--   dish_variant: 8 rows (notes describe producing a different dish)
--
-- All in a single transaction. Rolls back on any error.
-- ============================================================

BEGIN;

-- ============================================================
-- ANTI_PATTERN (6 rows)
-- All have notes containing "Anti-pattern" or "Anti-substitution" framing.
-- Most have original_id = substitute_id (technique anti-patterns).
-- ============================================================

UPDATE substitutions
SET classification = 'anti_pattern'::substitution_classification
WHERE id IN (
  'fa06ee21-7767-44c5-9103-4e3317a2e605',  -- off-season tomato anti-pattern (cheeseburger)
  'da0c5e90-a024-4a25-8259-c36d3ce5c4f9',  -- rolling pin (margherita)
  '4fd18d79-813e-4ca4-8406-602ff457d0b4',  -- pre-cooked sauce (margherita)
  '1827d158-f029-4341-a631-e05d2e9f34e4',  -- heavy cream for pork fat (tonkotsu)
  '82fe601c-ed89-4ec7-987b-504d32ee21c1',  -- braising instead of confit (carnitas)
  '5437e997-4c27-404d-9178-8b79f01988b6'   -- skipping crispy stage (carnitas)
);

-- ============================================================
-- DISH_VARIANT (8 rows)
-- Notes describe producing a different dish, not a variant of original.
-- ============================================================

UPDATE substitutions
SET classification = 'dish_variant'::substitution_classification
WHERE id IN (
  'f59e848c-0e93-4c48-9670-b58a08a3ec8f',  -- ground turkey instead of beef (turkey burger, different product)
  '84c0d776-765a-4d14-ae1c-936c37b8ec43',  -- plant-based patty (different product, vegan burger)
  'cf79a462-a81a-446c-9440-4222a8a539fc',  -- low-moisture American mozzarella (different pizza style, Italian-American not Neapolitan)
  'de3c6451-8642-4fa2-87be-4aeaa92096d7',  -- home oven 550F bake (notes: "not a Neapolitan pizza")
  'a282c598-b3bb-4e68-83b9-3f7477fae816',  -- udon for ramen noodles (notes: "now a different dish")
  'ae8d2f09-61ab-423b-87e6-c181a339710f',  -- chicken thigh chashu (notes: "rebrand as chicken chashu")
  '79e8024a-e766-410c-8627-cd5bb3628ca6',  -- chicken backs for pork bones (notes: "becomes paitan ramen, not tonkotsu")
  '7b8857d7-dabd-4a9c-92e3-23bef8f29164'   -- chicken thigh pollo carnitas (notes: "carnitas means pork")
);

-- ============================================================
-- REAL_SUBSTITUTION (43 rows via UPDATE WHERE classification IS NULL)
-- Everything remaining gets real_substitution. Done by negation
-- to catch any rows me may have miscounted.
-- ============================================================

UPDATE substitutions
SET classification = 'real_substitution'::substitution_classification
WHERE classification IS NULL;

COMMIT;

-- ============================================================
-- VERIFICATION
-- Run after to confirm the breakdown:
--
-- SELECT classification, COUNT(*) AS row_count
-- FROM substitutions
-- GROUP BY classification
-- ORDER BY classification;
--
-- Expected after backfill:
--   anti_pattern: 11 (5 from pad thai + 6 backfilled)
--   dish_variant: 8
--   real_substitution: 48 (5 from pad thai + 43 backfilled)
--   NULL: 0
--
-- Total: 67 (matches current substitutions count)
-- ============================================================
