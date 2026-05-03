// Edge Function: check-job
//
// Accepts GET /functions/v1/check-job?job_id=<uuid>
// Returns current job status, result if complete, error if failed.
// Frontend polls this every 5 sec until status is 'complete' or 'failed'.

import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

// CORS allowed origins. Production domain plus localhost for dev.
const ALLOWED_ORIGINS = [
  "https://menumathagent.com",
  "https://www.menumathagent.com",
  "http://localhost:3000",
]

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders(req) })
  }

  if (req.method !== "GET") {
    return jsonError(req, "method_not_allowed", "Use GET.", 405)
  }

  try {
    // ----- PARSE job_id FROM QUERY -----
    const url = new URL(req.url)
    const jobId = url.searchParams.get("job_id")

    if (!jobId || !UUID_REGEX.test(jobId)) {
      return jsonError(
        req,
        "invalid_job_id",
        "job_id query param must be a valid UUID.",
        400
      )
    }

    // ----- INIT SUPABASE CLIENT -----
    const supabaseUrl = Deno.env.get("SUPABASE_URL")
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
    if (!supabaseUrl || !supabaseKey) {
      return jsonError(req, "config_error", "Supabase credentials missing.", 500)
    }
    const supabase = createClient(supabaseUrl, supabaseKey)

    // ----- FETCH JOB ROW -----
    const { data: jobRows, error: jobError } = await supabase
      .from("decompose_jobs")
      .select(
        "id, dish_input, zip, month, status, sql_output, error_message, prompt_version, input_tokens, output_tokens, duration_seconds, created_at, started_at, completed_at"
      )
      .eq("id", jobId)
      .limit(1)

    if (jobError) {
      return jsonError(req, "db_query_failed", jobError.message, 500)
    }

    if (!jobRows || jobRows.length === 0) {
      return jsonError(req, "job_not_found", `No job with id ${jobId}`, 404)
    }

    const job = jobRows[0]

    // ----- BUILD RESPONSE BASED ON STATUS -----
    // Always return status + timestamps so frontend can show progress.
    // Only return sql_output when complete. Only return error_message when failed.

    const base = {
      job_id: job.id,
      status: job.status,
      dish_input: job.dish_input,
      zip: job.zip,
      month: job.month,
      created_at: job.created_at,
      started_at: job.started_at,
      completed_at: job.completed_at,
    }

    if (job.status === "complete") {
      return jsonOk(req, {
        ...base,
        sql_output: job.sql_output,
        prompt_version: job.prompt_version,
        input_tokens: job.input_tokens,
        output_tokens: job.output_tokens,
        duration_seconds: job.duration_seconds,
      })
    }

    if (job.status === "failed") {
      return jsonOk(req, {
        ...base,
        error_message: job.error_message,
        sql_output: job.sql_output, // may have partial output (e.g. truncated)
        duration_seconds: job.duration_seconds,
      })
    }

    // pending or running: just return status + timing for progress UI
    return jsonOk(req, base)

  } catch (e) {
    return jsonError(
      req,
      "unhandled_error",
      e instanceof Error ? e.message : String(e),
      500
    )
  }
})

// ============================================================
// HELPERS
// ============================================================

function corsHeaders(req: Request) {
  const origin = req.headers.get("origin") || ""
  const allow = ALLOWED_ORIGINS.includes(origin) ? origin : "https://menumathagent.com"
  return {
    "Access-Control-Allow-Origin": allow,
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
  }
}

function jsonOk(req: Request, payload: unknown) {
  return new Response(JSON.stringify(payload), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(req),
    },
  })
}

function jsonError(req: Request, code: string, message: string, status: number) {
  return new Response(JSON.stringify({ error: { code, message } }), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(req),
    },
  })
}