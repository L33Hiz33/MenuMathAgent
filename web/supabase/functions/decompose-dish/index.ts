// Edge Function: decompose-dish
//
// Accepts POST { dish, zip, month } from frontend.
// Validates input. Checks cache. If miss, calls Anthropic API with v1.2
// prompt from prompts table. Validates returned SQL. Executes against DB.
// Returns dish data.

import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// ============================================================
// CONFIG
// ============================================================

const ANTHROPIC_MODEL = "claude-sonnet-4-5-20250929"
const ANTHROPIC_MAX_TOKENS = 16000
const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"

// SQL keywords we will NEVER allow in engine output, even if the LLM goes off-rails.
const FORBIDDEN_SQL_KEYWORDS = [
  "DROP TABLE",
  "DROP DATABASE",
  "DROP SCHEMA",
  "TRUNCATE",
  "ALTER TABLE",
  "ALTER DATABASE",
  "GRANT",
  "REVOKE",
  "CREATE USER",
  "CREATE ROLE",
  "DELETE FROM",
  "UPDATE ",
]

// Dish input validation: letters, numbers, spaces, hyphens, parens, accents.
const DISH_NAME_REGEX = /^[\p{L}\p{N}\s\-()',.]{2,80}$/u

// ============================================================
// MAIN HANDLER
// ============================================================

Deno.serve(async (req) => {
  // CORS for browser calls
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
        dish: cachedDishes[0],
        message: "Pulled from cache.",
      })
    }

    // ----- LOAD ACTIVE PROMPT -----
    const { data: promptRows, error: promptError } = await supabase
      .from("prompts")
      .select("prompt_text, version")
      .eq("engine", "engine_b")
      .eq("is_active", true)
      .limit(1)

    if (promptError || !promptRows || promptRows.length === 0) {
      return jsonError(
        "prompt_not_found",
        "Active engine_b prompt not found in DB.",
        500
      )
    }

    const promptText = promptRows[0].prompt_text
    const promptVersion = promptRows[0].version

    // ----- CALL ANTHROPIC API -----
    const anthropicKey = Deno.env.get("ANTHROPIC_API_KEY")
    if (!anthropicKey) {
      return jsonError("config_error", "Anthropic API key missing.", 500)
    }

    const userMessage = buildUserMessage(dish, zip, month)

    const anthropicResponse = await fetch(ANTHROPIC_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": anthropicKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: ANTHROPIC_MODEL,
        max_tokens: ANTHROPIC_MAX_TOKENS,
        system: promptText,
        messages: [{ role: "user", content: userMessage }],
      }),
    })

    if (!anthropicResponse.ok) {
      const errText = await anthropicResponse.text()
      return jsonError(
        "anthropic_api_error",
        `Anthropic returned ${anthropicResponse.status}: ${errText}`,
        502
      )
    }

    const anthropicData = await anthropicResponse.json()
    const sqlOutput =
      anthropicData?.content?.[0]?.text ??
      ""

    if (!sqlOutput) {
      return jsonError("empty_engine_output", "Engine returned no content.", 502)
    }

    // ----- VALIDATE SQL OUTPUT -----
    const sqlUpper = sqlOutput.toUpperCase()
    const forbiddenHit = FORBIDDEN_SQL_KEYWORDS.find((kw) =>
      sqlUpper.includes(kw)
    )
    if (forbiddenHit) {
      return jsonError(
        "forbidden_sql",
        `Engine output contained forbidden SQL keyword: ${forbiddenHit}. Refusing to execute.`,
        500
      )
    }

    // ----- TODO Phase 4d: actually run the SQL against the DB -----
    // For now: return the engine output without executing it. Lets us inspect
    // what Engine B produced before wiring up SQL execution.

    return jsonOk({
      cached: false,
      prompt_version: promptVersion,
      dish_input: dish,
      zip,
      month,
      sql_output: sqlOutput,
      sql_executed: false,
      message:
        "Engine output received. SQL execution deferred to Phase 4d. Inspect sql_output to verify quality before enabling execution.",
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

function buildUserMessage(dish: string, zip: string, month: string): string {
  return `Decompose this dish for the database.

Dish: ${dish}
User region: zip ${zip}
Current month: ${month} 2026

Return SQL INSERT statements following the schema and conventions described in the system prompt. Use BEGIN/COMMIT transaction wrapper. All provenance must be 'llm_inferred_low_confidence'.`
}

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