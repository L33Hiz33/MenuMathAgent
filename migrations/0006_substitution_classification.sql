-- ============================================================
-- Migration: 0006_substitution_classification
-- DDL only. Zero INSERT statements.
--
-- Adds substitution_classification enum and column to substitutions
-- table to support Engine B v1.2's three-category substitution
-- framework:
--   - real_substitution: valid swap WITHIN dish identity; full tradeoff_notes
--   - anti_pattern: common error to avoid; warning content; low quality_match_score
--   - dish_variant: changes dish identity; should NOT be in substitutions
--                   (kept here for backward compatibility, but new entries
--                   should be flagged for future dish_relationships table)
--
-- New enum:
--   substitution_classification (real_substitution, anti_pattern, dish_variant)
--
-- New column:
--   substitutions.classification (substitution_classification, nullable)
--
-- Nullable so existing rows (from banh mi, tonkotsu, margherita,
-- cheeseburger, carnitas seeds) can have NULL until backfilled.
-- New rows from v1.2 onward MUST set classification.
--
-- Prior migrations applied:
--   0001 (April 26): initial 27-table schema
--   0002 (April 29): role taxonomy seed (36 roles)
--   0003 (April 27): recipe_sub_recipes, dish_pairings tables
--   0005 (April 29): regional_weight, seasonal_weight, validity_window_end_date
--
-- Migration number: 0006 (skipping 0004 reserved for catch-all monitoring view)
-- ============================================================

-- ============================================================
-- NEW ENUM: substitution_classification
-- ============================================================

create type substitution_classification as enum (
  'real_substitution',
  'anti_pattern',
  'dish_variant'
);

comment on type substitution_classification is
  'Three-category substitution framework from Engine B v1.2. real_substitution = valid swap within dish identity. anti_pattern = common error to avoid (low quality_match_score, warning notes). dish_variant = changes dish identity, should be linked at dish level via dish_relationships table (future).';

-- ============================================================
-- ADD COLUMN: substitutions.classification
-- ============================================================

alter table substitutions
  add column classification substitution_classification;

comment on column substitutions.classification is
  'v1.2 three-category classification. Nullable for backward compatibility. New rows from v1.2 onward must set this value. Used by downstream substitution engine to filter (real_substitution only) or surface as warnings (anti_pattern).';

-- ============================================================
-- INDEX SUPPORT
-- ============================================================

-- Substitution queries frequently filter by classification + role.
-- Composite index helps when engine narrows to real_substitutions only.
create index idx_substitutions_classification
  on substitutions(classification, role_id)
  where classification is not null;

-- Anti-pattern queries (for warning lookups) benefit from separate filter.
create index idx_substitutions_anti_patterns
  on substitutions(role_id)
  where classification = 'anti_pattern';

-- ============================================================
-- DONE
-- 1 new enum, 1 new column, 2 new indexes. No data inserted.
-- ============================================================

-- ============================================================
-- Verification queries (run after migration to confirm):
--
-- Confirm enum created:
-- SELECT typname FROM pg_type WHERE typname = 'substitution_classification';
-- Expected: 1 row.
--
-- Confirm enum values:
-- SELECT enumlabel FROM pg_enum
-- WHERE enumtypid = (SELECT oid FROM pg_type WHERE typname = 'substitution_classification')
-- ORDER BY enumsortorder;
-- Expected: real_substitution, anti_pattern, dish_variant
--
-- Confirm column added:
-- SELECT column_name, udt_name
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND table_name = 'substitutions'
--   AND column_name = 'classification';
-- Expected: 1 row, classification, substitution_classification
--
-- Confirm indexes:
-- SELECT indexname FROM pg_indexes
-- WHERE schemaname = 'public'
--   AND indexname IN ('idx_substitutions_classification', 'idx_substitutions_anti_patterns');
-- Expected: 2 rows.
-- ============================================================
