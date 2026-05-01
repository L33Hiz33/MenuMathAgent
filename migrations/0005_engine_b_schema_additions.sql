-- ============================================================
-- Migration: 0005_engine_b_schema_additions
-- DDL only. Zero INSERT statements.
--
-- RECONSTRUCTED file. Original was applied to Supabase but never
-- committed to git. Reconstructed on May 1, 2026 by inspecting
-- live schema and identifying delta from 0003.
--
-- Adds Engine B v1.1 support:
--   regional_weight_tier enum + column on substitutions
--   seasonal_weight_tier enum + column on substitutions
--   validity_window_end_date column on recipes
--
-- Allows substitution engine to weight swaps by user region
-- (sourceability) and current season (timing). Allows recipes
-- to declare a freshness window for seasonal/regional context.
--
-- Prior migrations applied:
--   0001 (April 26): initial 27-table schema
--   0002 (April 29): role taxonomy seed (36 roles)
--   0003 (April 27): recipe_sub_recipes, dish_pairings tables
--
-- Migration number: 0005 (skipping 0004 reserved for catch-all monitoring view)
-- ============================================================

-- ============================================================
-- NEW ENUMS
-- ============================================================

create type regional_weight_tier as enum (
  'low',
  'medium',
  'high'
);

comment on type regional_weight_tier is
  'Priority of a substitution for users in a given region. low = original is widely available, swap unnecessary. medium = swap is sometimes useful. high = original is hard to source locally, swap is real value.';

create type seasonal_weight_tier as enum (
  'off_season',
  'stable',
  'approaching_peak',
  'peak'
);

comment on type seasonal_weight_tier is
  'Seasonal context of a substitution. off_season = original is poor quality or expensive this time of year, swap is real value. stable = year-round availability. approaching_peak = original is improving and getting cheaper. peak = original is at its best, no swap needed.';

-- ============================================================
-- ADD COLUMNS TO substitutions
-- ============================================================

alter table substitutions
  add column regional_weight regional_weight_tier;

comment on column substitutions.regional_weight is
  'How relevant this substitution is for the users region. Set per substitution row at seed time. Used by Engine B v1.1+ to surface region-appropriate swaps first.';

alter table substitutions
  add column seasonal_weight seasonal_weight_tier;

comment on column substitutions.seasonal_weight is
  'Seasonal relevance of this substitution. Set per substitution row at seed time. Used by Engine B v1.1+ to surface time-appropriate swaps first.';

-- ============================================================
-- ADD COLUMN TO recipes
-- ============================================================

alter table recipes
  add column validity_window_end_date date;

comment on column recipes.validity_window_end_date is
  'Date through which the regional and seasonal context of this recipe row is considered current. Used by Engine B to flag stale recipes for re-decomposition.';

-- ============================================================
-- DONE
-- 2 new enums, 3 new columns. No data inserted.
-- ============================================================

-- ============================================================
-- Verification queries (run after migration to confirm):
--
-- Confirm enums created:
-- SELECT typname FROM pg_type WHERE typname IN ('regional_weight_tier', 'seasonal_weight_tier');
-- Expected: 2 rows.
--
-- Confirm enum values:
-- SELECT t.typname, e.enumlabel
-- FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid
-- WHERE t.typname IN ('regional_weight_tier', 'seasonal_weight_tier')
-- ORDER BY t.typname, e.enumsortorder;
-- Expected:
--   regional_weight_tier: low, medium, high
--   seasonal_weight_tier: off_season, stable, approaching_peak, peak
--
-- Confirm columns added:
-- SELECT table_name, column_name, udt_name
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND ((table_name = 'substitutions' AND column_name IN ('regional_weight', 'seasonal_weight'))
--        OR (table_name = 'recipes' AND column_name = 'validity_window_end_date'));
-- Expected: 3 rows.
-- ============================================================
