# decompose_dish_worker.ps1
#
# GitHub Actions worker. Runs on ubuntu-latest with PowerShell 7.
# Reads a pending decompose_jobs row, calls Anthropic, writes result back.
#
# Required env vars:
#   JOB_ID                       UUID of the decompose_jobs row
#   SUPABASE_URL                 e.g. https://xxx.supabase.co
#   SUPABASE_SERVICE_ROLE_KEY    service_role key (bypasses RLS)
#   ANTHROPIC_API_KEY            Anthropic API key

param(
    [Parameter(Mandatory=$true)] [string]$JobId
)

# ============================================================
# CONFIG
# ============================================================

$SupabaseUrl = $env:SUPABASE_URL
$ServiceKey = $env:SUPABASE_SERVICE_ROLE_KEY
$AnthropicKey = $env:ANTHROPIC_API_KEY

$Model = "claude-sonnet-4-5-20250929"
$MaxTokens = 32000
$AnthropicUrl = "https://api.anthropic.com/v1/messages"

if (-not $SupabaseUrl) { Write-Error "SUPABASE_URL not set"; exit 1 }
if (-not $ServiceKey) { Write-Error "SUPABASE_SERVICE_ROLE_KEY not set"; exit 1 }
if (-not $AnthropicKey) { Write-Error "ANTHROPIC_API_KEY not set"; exit 1 }

Write-Host "Worker starting for job: $JobId"

# ============================================================
# HELPER: Supabase REST API call
# ============================================================

function Invoke-SupabaseRest {
    param(
        [string]$Path,
        [string]$Method = "GET",
        [hashtable]$Body = $null
    )

    $Headers = @{
        "apikey" = $ServiceKey
        "Authorization" = "Bearer $ServiceKey"
        "Content-Type" = "application/json"
        "Prefer" = "return=representation"
    }

    $Url = "$SupabaseUrl/rest/v1/$Path"

    if ($Body) {
        $JsonBody = $Body | ConvertTo-Json -Depth 10
        $BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonBody)
        return Invoke-RestMethod -Uri $Url -Method $Method -Headers $Headers -Body $BodyBytes
    } else {
        return Invoke-RestMethod -Uri $Url -Method $Method -Headers $Headers
    }
}

# ============================================================
# STEP 1: Mark job as running, fetch inputs
# ============================================================

Write-Host "Marking job as running and fetching inputs..."

$NowIso = (Get-Date).ToUniversalTime().ToString("o")

$UpdateRunning = Invoke-SupabaseRest `
    -Path "decompose_jobs?id=eq.$JobId" `
    -Method "PATCH" `
    -Body @{
        status = "running"
        started_at = $NowIso
    }

if (-not $UpdateRunning -or $UpdateRunning.Count -eq 0) {
    Write-Error "Job $JobId not found in decompose_jobs"
    exit 1
}

$Job = $UpdateRunning[0]
$Dish = $Job.dish_input
$Zip = $Job.zip
$Month = $Job.month

Write-Host "Job loaded. Dish: $Dish, Zip: $Zip, Month: $Month"

# ============================================================
# STEP 2: Fetch active prompt from DB
# ============================================================

Write-Host "Fetching active engine_b prompt..."

$PromptRows = Invoke-SupabaseRest `
    -Path "prompts?engine=eq.engine_b&is_active=eq.true&select=prompt_text,version&limit=1"

if (-not $PromptRows -or $PromptRows.Count -eq 0) {
    Write-Error "No active engine_b prompt in DB"
    Invoke-SupabaseRest -Path "decompose_jobs?id=eq.$JobId" -Method "PATCH" -Body @{
        status = "failed"
        error_message = "No active engine_b prompt in DB"
        completed_at = (Get-Date).ToUniversalTime().ToString("o")
    }
    exit 1
}

$PromptText = $PromptRows[0].prompt_text
$PromptVersion = $PromptRows[0].version

Write-Host "Prompt loaded. Version: $PromptVersion. Length: $($PromptText.Length) chars."

# ============================================================
# STEP 3: Call Anthropic API
# ============================================================

$UserMessage = @"
Decompose this dish for the database.

Dish: $Dish
User region: zip $Zip
Current month: $Month 2026

Return SQL INSERT statements following the schema and conventions described in the system prompt. Use BEGIN/COMMIT transaction wrapper. All provenance must be 'llm_inferred_low_confidence'.
"@

$AnthropicHeaders = @{
    "x-api-key" = $AnthropicKey
    "anthropic-version" = "2023-06-01"
    "Content-Type" = "application/json"
}

$AnthropicBody = @{
    model = $Model
    max_tokens = $MaxTokens
    system = $PromptText
    messages = @(
        @{ role = "user"; content = $UserMessage }
    )
}

$BodyJson = $AnthropicBody | ConvertTo-Json -Depth 10
$BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($BodyJson)

Write-Host "Calling Anthropic. Model: $Model. Max tokens: $MaxTokens"
$StartTime = Get-Date

try {
    $Response = Invoke-RestMethod `
        -Uri $AnthropicUrl `
        -Method POST `
        -Headers $AnthropicHeaders `
        -Body $BodyBytes `
        -TimeoutSec 480

    $Elapsed = (Get-Date) - $StartTime
    Write-Host "Anthropic response received in $([math]::Round($Elapsed.TotalSeconds, 1)) seconds."
}
catch {
    $ErrorBody = ""
    if ($_.Exception.Response) {
        $ErrorStream = $_.Exception.Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader($ErrorStream)
        $ErrorBody = $Reader.ReadToEnd()
    }
    $ErrMsg = "Anthropic API call failed: $_. Body: $ErrorBody"
    Write-Host $ErrMsg

    Invoke-SupabaseRest -Path "decompose_jobs?id=eq.$JobId" -Method "PATCH" -Body @{
        status = "failed"
        error_message = $ErrMsg
        completed_at = (Get-Date).ToUniversalTime().ToString("o")
    }
    exit 1
}

# ============================================================
# STEP 4: Extract output, check for truncation, write back
# ============================================================

$OutputText = $Response.content[0].text
$InputTokens = $Response.usage.input_tokens
$OutputTokens = $Response.usage.output_tokens
$StopReason = $Response.stop_reason

if (-not $OutputText) {
    Invoke-SupabaseRest -Path "decompose_jobs?id=eq.$JobId" -Method "PATCH" -Body @{
        status = "failed"
        error_message = "Anthropic returned empty content"
        completed_at = (Get-Date).ToUniversalTime().ToString("o")
    }
    Write-Error "Empty content from Anthropic"
    exit 1
}

Write-Host "Output length: $($OutputText.Length) chars. Tokens in/out: $InputTokens/$OutputTokens. stop_reason: $StopReason"

# Truncation check: if Anthropic stopped because we hit the token ceiling,
# the output is incomplete. Mark the job as failed but keep the partial
# output for inspection.
if ($StopReason -eq "max_tokens") {
    $TruncMsg = "Output truncated at max_tokens=$MaxTokens. stop_reason=max_tokens. Real output had $OutputTokens output tokens. Increase max_tokens or split engine work."
    Invoke-SupabaseRest -Path "decompose_jobs?id=eq.$JobId" -Method "PATCH" -Body @{
        status = "failed"
        error_message = $TruncMsg
        sql_output = $OutputText
        input_tokens = $InputTokens
        output_tokens = $OutputTokens
        prompt_version = $PromptVersion
        duration_seconds = [math]::Round($Elapsed.TotalSeconds, 2)
        completed_at = (Get-Date).ToUniversalTime().ToString("o")
    }
    Write-Error $TruncMsg
    exit 1
}

Write-Host "Writing result to DB..."

Invoke-SupabaseRest -Path "decompose_jobs?id=eq.$JobId" -Method "PATCH" -Body @{
    status = "complete"
    sql_output = $OutputText
    prompt_version = $PromptVersion
    input_tokens = $InputTokens
    output_tokens = $OutputTokens
    duration_seconds = [math]::Round($Elapsed.TotalSeconds, 2)
    completed_at = (Get-Date).ToUniversalTime().ToString("o")
}

Write-Host "Job complete."