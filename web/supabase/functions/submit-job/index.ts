// Edge Function: submit-job
//
// Accepts POST { dish, zip, month } from frontend.
// Validates input. Checks cache.
// If cache miss: creates decompose_jobs row, triggers GitHub Action,
// returns job_id immediately.
// If cache hit: returns cached dish, no job created.

import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// ============================================================
// CONFIG
// ============================================================

const GITHUB_OWNER = "L33Hiz33"
const GITHUB_REPO = "MenuMathAgent"
const GITHUB_WORKFLOW_FILE = "decompose-dish.yml"
const GITHUB_REF = "main"

// Dish input validation: letters, numbers, spaces, hyphens, parens, accents.
const DISH_NAME_REGEX = /^[\p{L}\p{N}\s\-()',.]{2,80}$/u

// ============================================================
// MAIN HANDLER
// ============================================================

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders() })
  }

  if (req.method !== "POST") {
    return jsonError("method_not_allowed", "Use POST.", 405)
  }

  try {
    const body = await req.json()
    const { dish, zip, month } = body || {}

    // ----- INPUT VALIDATION -----
    if (typeof dish !== "string" || !DISH_NAME_REGEX.test(dish)) {
      return jsonError(
        "invalid_dish",
        "Dish name must be 2-80 characters, letters/numbers/spaces/hyphens only.",
        400
      )
    }

    if (typeof zip !== "string" || !/^\d{5}$/.test(zip)) {
      return jsonError("invalid_zip", "Zip must be 5 digits.", 400)
    }

    if (typeof month !== "string" || month.length === 0) {
      return jsonError("invalid_month", "Month is required.", 400)
    }

    // ----- INIT SUPABASE CLIENT -----
    const supabaseUrl = Deno.env.get("SUPABASE_URL")
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
    if (!supabaseUrl || !supabaseKey) {
      return jsonError("config_error", "Supabase credentials missing.", 500)
    }
    const supabase = createClient(supabaseUrl, supabaseKey)

    // ----- CACHE CHECK -----
    const dishLower = dish.trim().toLowerCase()
    const { data: cachedDishes, error: cacheError } = await supabase
      .from("dishes")
      .select("*")
      .ilike("name", `${dishLower}%`)
      .limit(1)

    if (cacheError) {
      return jsonError("cache_lookup_failed", cacheError.message, 500)
    }

    if (cachedDishes && cachedDishes.length > 0) {
      return jsonOk({
        cached: true,
        job_id: null,
        dish: cachedDishes[0],
        message: "Pulled from cache. No job needed.",
      })
    }

    // ----- CACHE MISS: CREATE JOB ROW -----
    const { data: jobRows, error: jobError } = await supabase
      .from("decompose_jobs")
      .insert({
        dish_input: dish.trim(),
        zip,
        month,
        status: "pending",
      })
      .select("id")
      .limit(1)

    if (jobError || !jobRows || jobRows.length === 0) {
      return jsonError(
        "job_create_failed",
        jobError?.message || "Failed to create job row.",
        500
      )
    }

    const jobId = jobRows[0].id

    // ----- TRIGGER GITHUB ACTION -----
    const githubPat = Deno.env.get("GITHUB_ACTIONS_PAT")
    if (!githubPat) {
      return jsonError("config_error", "GitHub PAT missing.", 500)
    }

    const dispatchUrl = `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/workflows/${GITHUB_WORKFLOW_FILE}/dispatches`

    const dispatchResponse = await fetch(dispatchUrl, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${githubPat}`,
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        ref: GITHUB_REF,
        inputs: {
          job_id: jobId,
        },
      }),
    })

    if (!dispatchResponse.ok) {
      const errText = await dispatchResponse.text()

      // Mark job as failed since worker won't run
      await supabase
        .from("decompose_jobs")
        .update({
          status: "failed",
          error_message: `GitHub Action dispatch failed: ${dispatchResponse.status}: ${errText}`,
          completed_at: new Date().toISOString(),
        })
        .eq("id", jobId)

      return jsonError(
        "github_dispatch_failed",
        `GitHub returned ${dispatchResponse.status}: ${errText}`,
        502
      )
    }

    // ----- SUCCESS: RETURN JOB ID -----
    return jsonOk({
      cached: false,
      job_id: jobId,
      message: "Job created. Worker triggered. Poll check-job endpoint with job_id.",
    })

  } catch (e) {
    return jsonError(
      "unhandled_error",
      e instanceof Error ? e.message : String(e),
      500
    )
  }
})

// ============================================================
// HELPERS
// ============================================================

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
  }
}

function jsonOk(payload: unknown) {
  return new Response(JSON.stringify(payload), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(),
    },
  })
}

function jsonError(code: string, message: string, status: number) {
  return new Response(JSON.stringify({ error: { code, message } }), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(),
    },
  })
}