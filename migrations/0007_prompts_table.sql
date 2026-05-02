-- ============================================================
-- Migration: 0007_prompts_table
-- Adds the prompts table to store engine prompts with version history.
--
-- Purpose: Engine B (and future engines C, D) read their prompt from
-- this table at runtime instead of having it hardcoded.
--
-- Benefits:
--   - Update prompt without redeploying Edge Function
--   - Version history kept in DB
--   - Only one row per engine is active at a time
-- ============================================================

BEGIN;

CREATE TABLE prompts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  engine TEXT NOT NULL,
  version TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT FALSE,
  prompt_text TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (engine, version)
);

COMMENT ON TABLE prompts IS
  'Versioned prompts for AI engines. Edge Functions read active prompt at runtime.';

COMMENT ON COLUMN prompts.engine IS
  'Engine name: engine_b, engine_c, etc.';

COMMENT ON COLUMN prompts.version IS
  'Version string: 1.2, 1.3, etc.';

COMMENT ON COLUMN prompts.is_active IS
  'Only one row per engine should be TRUE. Edge Function reads WHERE is_active=TRUE.';

-- Index for the runtime query
CREATE INDEX idx_prompts_active
  ON prompts (engine, is_active)
  WHERE is_active = TRUE;

COMMIT;