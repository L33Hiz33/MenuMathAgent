'use client'

import { useState, useEffect, useRef } from 'react'

const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

const POLL_INTERVAL_MS = 5000
const MAX_POLL_DURATION_MS = 10 * 60 * 1000 // 10 minutes

type JobStatus = 'idle' | 'submitting' | 'cache_hit' | 'pending' | 'running' | 'complete' | 'failed'

interface CacheHitResponse {
  cached: true
  job_id: null
  dish: {
    id: string
    name: string
    description: string
    [key: string]: unknown
  }
}

interface JobCreatedResponse {
  cached: false
  job_id: string
  message: string
}

interface JobStatusResponse {
  job_id: string
  status: 'pending' | 'running' | 'complete' | 'failed'
  dish_input: string
  zip: string
  month: string
  sql_output?: string
  error_message?: string
  prompt_version?: string
  input_tokens?: number
  output_tokens?: number
  duration_seconds?: number
  created_at: string
  started_at?: string
  completed_at?: string
}

export default function RecipeForm() {
  const currentMonth = new Date().getMonth()

  const [dishName, setDishName] = useState('')
  const [zipCode, setZipCode] = useState('')
  const [month, setMonth] = useState(MONTHS[currentMonth])
  const [zipError, setZipError] = useState('')

  const [jobStatus, setJobStatus] = useState<JobStatus>('idle')
  const [jobId, setJobId] = useState<string | null>(null)
  const [cachedDish, setCachedDish] = useState<CacheHitResponse['dish'] | null>(null)
  const [jobResult, setJobResult] = useState<JobStatusResponse | null>(null)
  const [errorMessage, setErrorMessage] = useState<string>('')
  const [pollStartTime, setPollStartTime] = useState<number | null>(null)

  const pollTimerRef = useRef<NodeJS.Timeout | null>(null)

  // Cleanup polling on unmount or when status moves out of polling
  useEffect(() => {
    return () => {
      if (pollTimerRef.current) {
        clearInterval(pollTimerRef.current)
      }
    }
  }, [])

  useEffect(() => {
    if (jobStatus !== 'pending' && jobStatus !== 'running') {
      if (pollTimerRef.current) {
        clearInterval(pollTimerRef.current)
        pollTimerRef.current = null
      }
      return
    }

    if (!jobId) return

    const pollOnce = async () => {
      try {
        const elapsed = pollStartTime ? Date.now() - pollStartTime : 0
        if (elapsed > MAX_POLL_DURATION_MS) {
          setErrorMessage('Polling timed out after 10 minutes. Job may still be running. Try again later.')
          setJobStatus('failed')
          return
        }

        const response = await fetch(
          `${SUPABASE_URL}/functions/v1/check-job?job_id=${jobId}`,
          {
            method: 'GET',
            headers: {
              Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
            },
          }
        )

        if (!response.ok) {
          const errBody = await response.json().catch(() => ({}))
          setErrorMessage(`Polling error: ${response.status} ${errBody?.error?.message || 'unknown'}`)
          setJobStatus('failed')
          return
        }

        const data: JobStatusResponse = await response.json()

        if (data.status === 'complete') {
          setJobResult(data)
          setJobStatus('complete')
        } else if (data.status === 'failed') {
          setJobResult(data)
          setErrorMessage(data.error_message || 'Job failed without explanation.')
          setJobStatus('failed')
        } else {
          // pending or running: update status and keep polling
          setJobStatus(data.status)
        }
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e)
        setErrorMessage(`Network error during polling: ${msg}`)
        setJobStatus('failed')
      }
    }

    // Poll immediately, then on interval
    pollOnce()
    pollTimerRef.current = setInterval(pollOnce, POLL_INTERVAL_MS)

    return () => {
      if (pollTimerRef.current) {
        clearInterval(pollTimerRef.current)
        pollTimerRef.current = null
      }
    }
  }, [jobStatus, jobId, pollStartTime])

  function handleZipChange(value: string) {
    const digitsOnly = value.replace(/\D/g, '').slice(0, 5)
    setZipCode(digitsOnly)
    if (digitsOnly.length > 0 && digitsOnly.length < 5) {
      setZipError('Zip code must be 5 digits')
    } else {
      setZipError('')
    }
  }

  function resetForm() {
    setJobStatus('idle')
    setJobId(null)
    setCachedDish(null)
    setJobResult(null)
    setErrorMessage('')
    setPollStartTime(null)
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    if (zipCode.length !== 5) {
      setZipError('Zip code must be 5 digits')
      return
    }
    if (!dishName.trim()) return

    // Reset previous result state
    setJobId(null)
    setCachedDish(null)
    setJobResult(null)
    setErrorMessage('')
    setJobStatus('submitting')

    try {
      const response = await fetch(`${SUPABASE_URL}/functions/v1/submit-job`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({
          dish: dishName.trim(),
          zip: zipCode,
          month,
        }),
      })

      if (!response.ok) {
        const errBody = await response.json().catch(() => ({}))
        setErrorMessage(`Submit error: ${response.status} ${errBody?.error?.message || 'unknown'}`)
        setJobStatus('failed')
        return
      }

      const data: CacheHitResponse | JobCreatedResponse = await response.json()

      if (data.cached) {
        setCachedDish(data.dish)
        setJobStatus('cache_hit')
        return
      }

      // Cache miss: start polling
      setJobId(data.job_id)
      setPollStartTime(Date.now())
      setJobStatus('pending')
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e)
      setErrorMessage(`Network error: ${msg}`)
      setJobStatus('failed')
    }
  }

  const isWorking = jobStatus === 'submitting' || jobStatus === 'pending' || jobStatus === 'running'
  const isDone = jobStatus === 'complete' || jobStatus === 'failed' || jobStatus === 'cache_hit'

  return (
    <section
      className="relative border-t border-stone-900/15 bg-[#f5f0e8] py-20"
      style={{ fontFamily: 'var(--font-inter), system-ui, sans-serif' }}
    >
      <div className="mx-auto w-full max-w-6xl px-8">
        {/* Section header */}
        <div className="mb-12 grid grid-cols-12 gap-8">
          <div className="col-span-12 md:col-span-8">
            <div className="mb-4 flex items-center gap-3">
              <span className="h-px w-8 bg-stone-900" />
              <span className="text-[11px] uppercase tracking-[0.3em] text-stone-700">
                The working tool
              </span>
            </div>

            <h2
              className="mb-4 text-4xl leading-tight tracking-tight text-stone-900 sm:text-5xl"
              style={{
                fontFamily: 'var(--font-playfair), Georgia, serif',
                fontWeight: 700,
              }}
            >
              Tell us what you&apos;re cooking.
            </h2>

            <p className="max-w-xl text-base leading-relaxed text-stone-600">
              Drop in a dish name and your location. We read the food economy
              and tell you what to substitute, what&apos;s in season, and
              what&apos;s costing more this week.
            </p>

            <div className="mt-6 inline-flex items-center gap-3 border border-amber-700/30 bg-amber-50 px-4 py-2 text-xs uppercase tracking-[0.2em] text-amber-900">
              <span className="inline-block h-1.5 w-1.5 animate-pulse rounded-full bg-amber-700" />
              <span>Live engine · async via GitHub Actions · expect 3-5 min on cache miss</span>
            </div>
          </div>
        </div>

        {/* Form */}
        <div className="grid grid-cols-12 gap-8">
          <form
            onSubmit={handleSubmit}
            className="col-span-12 md:col-span-8 space-y-6"
          >
            {/* Dish name */}
            <div>
              <label
                htmlFor="dishName"
                className="mb-2 block text-[11px] uppercase tracking-[0.25em] text-stone-700"
              >
                Dish
              </label>
              <input
                id="dishName"
                type="text"
                value={dishName}
                onChange={(e) => setDishName(e.target.value)}
                placeholder="e.g. Tacos al pastor, Banh mi, Tonkotsu ramen"
                disabled={isWorking}
                className="w-full border-b border-stone-900/30 bg-transparent py-3 text-lg text-stone-900 placeholder:text-stone-400 focus:border-stone-900 focus:outline-none disabled:opacity-50"
                style={{ fontFamily: 'var(--font-playfair), Georgia, serif' }}
                required
              />
            </div>

            {/* Zip + Month row */}
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label
                  htmlFor="zipCode"
                  className="mb-2 block text-[11px] uppercase tracking-[0.25em] text-stone-700"
                >
                  Zip Code
                </label>
                <input
                  id="zipCode"
                  type="text"
                  inputMode="numeric"
                  value={zipCode}
                  onChange={(e) => handleZipChange(e.target.value)}
                  placeholder="77002"
                  maxLength={5}
                  disabled={isWorking}
                  className="w-full border-b border-stone-900/30 bg-transparent py-3 text-lg text-stone-900 placeholder:text-stone-400 focus:border-stone-900 focus:outline-none disabled:opacity-50"
                  style={{ fontFamily: 'var(--font-playfair), Georgia, serif' }}
                  required
                />
                {zipError && (
                  <p className="mt-2 text-xs text-red-700">{zipError}</p>
                )}
              </div>

              <div>
                <label
                  htmlFor="month"
                  className="mb-2 block text-[11px] uppercase tracking-[0.25em] text-stone-700"
                >
                  Month
                </label>
                <select
                  id="month"
                  value={month}
                  onChange={(e) => setMonth(e.target.value)}
                  disabled={isWorking}
                  className="w-full appearance-none border-b border-stone-900/30 bg-transparent py-3 text-lg text-stone-900 focus:border-stone-900 focus:outline-none disabled:opacity-50"
                  style={{ fontFamily: 'var(--font-playfair), Georgia, serif' }}
                >
                  {MONTHS.map((m) => (
                    <option key={m} value={m}>
                      {m}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Submit / Reset */}
            <div className="flex flex-wrap items-center gap-4 pt-6">
              <button
                type="submit"
                disabled={isWorking}
                className="group inline-flex items-center gap-3 bg-stone-900 px-8 py-4 text-sm uppercase tracking-[0.25em] text-stone-50 transition hover:bg-stone-800 disabled:opacity-40"
              >
                <span>{isWorking ? 'Working…' : 'Read the markets'}</span>
                {!isWorking && (
                  <span className="transition-transform group-hover:translate-x-1">→</span>
                )}
              </button>

              {isDone && (
                <button
                  type="button"
                  onClick={resetForm}
                  className="text-xs uppercase tracking-[0.25em] text-stone-600 underline-offset-4 hover:underline"
                >
                  New query
                </button>
              )}
            </div>
          </form>

          {/* Sidebar info */}
          <aside className="col-span-12 md:col-span-4">
            <div className="border border-stone-900/15 bg-stone-50/40 p-6 backdrop-blur-sm">
              <div className="mb-3 text-[10px] uppercase tracking-[0.25em] text-stone-700">
                What you&apos;ll get back
              </div>

              <ul className="space-y-3 text-sm text-stone-700">
                <li className="flex gap-3">
                  <span className="text-stone-500">01</span>
                  <span>Cost-aware substitutions ranked by impact</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-stone-500">02</span>
                  <span>Anti-patterns to avoid (swaps that break the dish)</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-stone-500">03</span>
                  <span>Seasonal context for each ingredient</span>
                </li>
                <li className="flex gap-3">
                  <span className="text-stone-500">04</span>
                  <span>Honest answer on whether to make it this week</span>
                </li>
              </ul>
            </div>
          </aside>
        </div>

        {/* Status / Result panel */}
        {jobStatus !== 'idle' && (
          <div className="mt-12 grid grid-cols-12 gap-8">
            <div className="col-span-12">
              {/* WORKING STATES */}
              {isWorking && (
                <div className="border border-stone-900/15 bg-stone-50/60 p-8">
                  <div className="mb-4 flex items-center gap-3">
                    <span className="inline-block h-2 w-2 animate-pulse rounded-full bg-amber-700" />
                    <span className="text-[11px] uppercase tracking-[0.3em] text-stone-700">
                      {jobStatus === 'submitting' && 'Submitting'}
                      {jobStatus === 'pending' && 'Worker queued'}
                      {jobStatus === 'running' && 'Engine running'}
                    </span>
                  </div>
                  <p
                    className="mb-2 text-2xl leading-snug text-stone-900"
                    style={{ fontFamily: 'var(--font-playfair), Georgia, serif' }}
                  >
                    {jobStatus === 'submitting' && 'Sending your dish to the engine.'}
                    {jobStatus === 'pending' && 'Worker is starting up on GitHub Actions.'}
                    {jobStatus === 'running' && 'Engine is reading the food economy and decomposing your dish.'}
                  </p>
                  <p className="text-sm text-stone-600">
                    {jobStatus === 'submitting' && 'A second or two.'}
                    {jobStatus === 'pending' && '~30-60 seconds for cold start.'}
                    {jobStatus === 'running' && '~3-4 minutes total. Self-evaluation iteration loop is the slow part.'}
                  </p>
                </div>
              )}

              {/* CACHE HIT */}
              {jobStatus === 'cache_hit' && cachedDish && (
                <div className="border border-stone-900/15 bg-stone-50/60 p-8">
                  <div className="mb-4 flex items-center gap-3">
                    <span className="inline-block h-2 w-2 rounded-full bg-emerald-700" />
                    <span className="text-[11px] uppercase tracking-[0.3em] text-stone-700">
                      Cache hit
                    </span>
                  </div>
                  <h3
                    className="mb-3 text-3xl leading-tight text-stone-900"
                    style={{ fontFamily: 'var(--font-playfair), Georgia, serif', fontWeight: 700 }}
                  >
                    {cachedDish.name as string}
                  </h3>
                  <p className="max-w-3xl text-base leading-relaxed text-stone-700">
                    {cachedDish.description as string}
                  </p>
                  <p className="mt-4 text-xs text-stone-500">
                    Pulled from cache. Full decomposition wiring deferred to Phase 6.
                  </p>
                </div>
              )}

              {/* COMPLETE */}
              {jobStatus === 'complete' && jobResult && (
                <div className="border border-stone-900/15 bg-stone-50/60 p-8">
                  <div className="mb-4 flex items-center gap-3">
                    <span className="inline-block h-2 w-2 rounded-full bg-emerald-700" />
                    <span className="text-[11px] uppercase tracking-[0.3em] text-stone-700">
                      Complete
                    </span>
                    <span className="text-[11px] text-stone-500">
                      v{jobResult.prompt_version} ·{' '}
                      {jobResult.duration_seconds?.toFixed(0)}s ·{' '}
                      {jobResult.output_tokens} output tokens
                    </span>
                  </div>

                  <h3
                    className="mb-4 text-3xl leading-tight text-stone-900"
                    style={{ fontFamily: 'var(--font-playfair), Georgia, serif', fontWeight: 700 }}
                  >
                    {jobResult.dish_input}
                  </h3>

                  <pre className="max-h-[600px] overflow-auto whitespace-pre-wrap break-words border border-stone-300 bg-white p-4 text-xs leading-relaxed text-stone-800">
                    {jobResult.sql_output}
                  </pre>
                </div>
              )}

              {/* FAILED */}
              {jobStatus === 'failed' && (
                <div className="border border-red-300 bg-red-50 p-8">
                  <div className="mb-4 flex items-center gap-3">
                    <span className="inline-block h-2 w-2 rounded-full bg-red-700" />
                    <span className="text-[11px] uppercase tracking-[0.3em] text-red-900">
                      Failed
                    </span>
                  </div>
                  <p className="text-base leading-relaxed text-red-900">
                    {errorMessage || 'Job failed without explanation.'}
                  </p>
                  {jobResult?.sql_output && (
                    <details className="mt-4 text-sm text-red-900">
                      <summary className="cursor-pointer underline-offset-4 hover:underline">
                        Partial output
                      </summary>
                      <pre className="mt-3 max-h-[400px] overflow-auto whitespace-pre-wrap break-words border border-red-300 bg-white p-3 text-xs text-stone-800">
                        {jobResult.sql_output}
                      </pre>
                    </details>
                  )}
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </section>
  )
}