# Test script: calls Anthropic API directly with v1.2 prompt for a single dish.
# Skips Supabase Edge Function. Validates that:
#   - Anthropic API key works
#   - Model string is right
#   - Prompt produces real SQL output for a fresh dish
#
# Usage:
#   cd C:\Users\hisey\MenuMathAgent
#   .\scripts\test_anthropic_direct.ps1 -Dish "Croque Madame" -Zip "77002" -Month "April"

param(
    [Parameter(Mandatory=$true)] [string]$Dish,
    [Parameter(Mandatory=$true)] [string]$Zip,
    [Parameter(Mandatory=$true)] [string]$Month
)

# ============================================================
# CONFIG
# ============================================================

$RepoRoot = Split-Path -Parent $PSScriptRoot
$EnvFile = Join-Path $RepoRoot "web\.env.local"
$PromptFile = Join-Path $RepoRoot "prompts\engine_b_v1_2.md"
$OutputFile = Join-Path $RepoRoot "scripts\anthropic_test_output_$($Dish -replace '[^a-zA-Z0-9]','_').txt"

$Model = "claude-sonnet-4-5-20250929"
$MaxTokens = 16000
$ApiUrl = "https://api.anthropic.com/v1/messages"

# ============================================================
# STEP 1: Read API key from .env.local
# ============================================================

if (-not (Test-Path $EnvFile)) {
    Write-Error "Could not find $EnvFile. Make sure .env.local exists in web/ folder."
    exit 1
}

$ApiKey = $null
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^ANTHROPIC_API_KEY=(.+)$') {
        $ApiKey = $matches[1].Trim()
    }
}

if (-not $ApiKey) {
    Write-Error "ANTHROPIC_API_KEY not found in $EnvFile"
    exit 1
}

Write-Host "API key loaded. Length: $($ApiKey.Length) chars." -ForegroundColor Green

# ============================================================
# STEP 2: Read v1.2 prompt from local file (extract PROMPT block)
# ============================================================

if (-not (Test-Path $PromptFile)) {
    Write-Error "Could not find $PromptFile"
    exit 1
}

$RawPrompt = Get-Content $PromptFile -Raw -Encoding UTF8

# Extract content between first triple backtick and last triple backtick
$Pattern = '(?s)```(?:.*?)\r?\n(.+?)```'
$Matches = [regex]::Match($RawPrompt, $Pattern)

if (-not $Matches.Success) {
    Write-Error "Could not find PROMPT block (triple-backtick fenced) in $PromptFile"
    exit 1
}

$PromptText = $Matches.Groups[1].Value.Trim()

Write-Host "Prompt loaded. Length: $($PromptText.Length) chars." -ForegroundColor Green

# ============================================================
# STEP 3: Build user message
# ============================================================

$UserMessage = @"
Decompose this dish for the database.

Dish: $Dish
User region: zip $Zip
Current month: $Month 2026

Return SQL INSERT statements following the schema and conventions described in the system prompt. Use BEGIN/COMMIT transaction wrapper. All provenance must be 'llm_inferred_low_confidence'.
"@

Write-Host "User message built." -ForegroundColor Green

# ============================================================
# STEP 4: Call Anthropic API
# ============================================================

$Headers = @{
    "x-api-key" = $ApiKey
    "anthropic-version" = "2023-06-01"
    "Content-Type" = "application/json"
}

$BodyHashtable = @{
    model = $Model
    max_tokens = $MaxTokens
    system = $PromptText
    messages = @(
        @{
            role = "user"
            content = $UserMessage
        }
    )
}

$Body = $BodyHashtable | ConvertTo-Json -Depth 10
$BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)

Write-Host "Calling Anthropic API. Model: $Model. This may take 60-180 seconds..." -ForegroundColor Yellow
$StartTime = Get-Date

try {
    $Response = Invoke-RestMethod `
        -Uri $ApiUrl `
        -Method POST `
        -Headers $Headers `
        -Body $BodyBytes `
        -TimeoutSec 300

    $Elapsed = (Get-Date) - $StartTime
    Write-Host "Response received in $([math]::Round($Elapsed.TotalSeconds, 1)) seconds." -ForegroundColor Green
}
catch {
    Write-Host "API call failed." -ForegroundColor Red
    if ($_.Exception.Response) {
        $ErrorStream = $_.Exception.Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader($ErrorStream)
        $ErrorBody = $Reader.ReadToEnd()
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Response body:" -ForegroundColor Red
        Write-Host $ErrorBody -ForegroundColor Red
    } else {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    exit 1
}

# ============================================================
# STEP 5: Extract output and save to file
# ============================================================

$OutputText = $Response.content[0].text

if (-not $OutputText) {
    Write-Error "No content in API response."
    exit 1
}

$OutputText | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "" 
Write-Host "===== SUCCESS =====" -ForegroundColor Green
Write-Host "Output saved to: $OutputFile"
Write-Host "Output length: $($OutputText.Length) chars"
Write-Host ""
Write-Host "Token usage:"
Write-Host "  Input tokens: $($Response.usage.input_tokens)"
Write-Host "  Output tokens: $($Response.usage.output_tokens)"
Write-Host ""
Write-Host "First 30 lines of output:"
Write-Host "----------------------------------------"
$OutputText.Split("`n") | Select-Object -First 30 | ForEach-Object { Write-Host $_ }
Write-Host "----------------------------------------"