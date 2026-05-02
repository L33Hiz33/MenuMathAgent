-- ============================================================
-- Migration: 0009_decompose_jobs_table
-- Adds the decompose_jobs table for async engine call tracking.
--
-- Purpose: Engine B calls take ~215 seconds. Edge Functions drop
-- client connections at 60-90s. Async pattern needed:
--   1. Frontend submits job -> Edge Function creates row, returns id
--   2. Background task calls Anthropic, updates row when done
--   3. Frontend polls by id until status = 'complete' or 'failed'
-- ============================================================

BEGIN;

-- Status values for the job lifecycle
CREATE TYPE job_status AS ENUM (
  'pending',     -- created, not yet started
  'running',     -- background task picked it up
  'complete',    -- Anthropic returned, sql_output populated
  'failed'       -- something broke, see error_message
);

CREATE TABLE decompose_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dish_input TEXT NOT NULL,
  zip TEXT NOT NULL,
  month TEXT NOT NULL,
  status job_status NOT NULL DEFAULT 'pending',
  sql_output TEXT,
  error_message TEXT,
  prompt_version TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  duration_seconds NUMERIC(8,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

COMMENT ON TABLE decompose_jobs IS
  'Async tracking for Engine B decomposition calls. Frontend polls by id.';

COMMENT ON COLUMN decompose_jobs.status IS
  'pending -> running -> complete OR failed. One-way transitions.';

COMMENT ON COLUMN decompose_jobs.sql_output IS
  'Engine output. Populated when status = complete. NULL otherwise.';

COMMENT ON COLUMN decompose_jobs.error_message IS
  'Failure reason. Populated when status = failed. NULL otherwise.';

COMMENT ON COLUMN decompose_jobs.duration_seconds IS
  'Wall clock time from job start to Anthropic response. For ops tracking.';

-- Index for polling: frontend queries by id, backend queries pending jobs
CREATE INDEX idx_decompose_jobs_status_created
  ON decompose_jobs (status, created_at);

COMMIT;