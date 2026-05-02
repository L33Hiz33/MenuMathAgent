'use client'

import { useState } from 'react'

const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]

export default function RecipeForm() {
  const currentMonth = new Date().getMonth() // 0-indexed

  const [dishName, setDishName] = useState('')
  const [zipCode, setZipCode] = useState('')
  const [month, setMonth] = useState(MONTHS[currentMonth])
  const [zipError, setZipError] = useState('')

  function handleZipChange(value: string) {
    // Only allow digits, max 5
    const digitsOnly = value.replace(/\D/g, '').slice(0, 5)
    setZipCode(digitsOnly)

    if (digitsOnly.length > 0 && digitsOnly.length < 5) {
      setZipError('Zip code must be 5 digits')
    } else {
      setZipError('')
    }
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    if (zipCode.length !== 5) {
      setZipError('Zip code must be 5 digits')
      return
    }

    if (!dishName.trim()) {
      return
    }

    console.log('Form submitted:', { dishName, zipCode, month })
    alert(`Thanks!\n\nMenu Math Agent is in pre-launch development. Your input has been received but not yet processed.\n\nDish: ${dishName}\nZip: ${zipCode}\nMonth: ${month}\n\nFollow along: github.com/L33Hiz33/MenuMathAgent`)
  }

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
              <span>Pre-launch · form preview only · backend coming soon</span>
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
                className="w-full border-b border-stone-900/30 bg-transparent py-3 text-lg text-stone-900 placeholder:text-stone-400 focus:border-stone-900 focus:outline-none"
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
                  className="w-full border-b border-stone-900/30 bg-transparent py-3 text-lg text-stone-900 placeholder:text-stone-400 focus:border-stone-900 focus:outline-none"
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
                  className="w-full appearance-none border-b border-stone-900/30 bg-transparent py-3 text-lg text-stone-900 focus:border-stone-900 focus:outline-none"
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

            {/* Submit */}
            <div className="pt-6">
              <button
                type="submit"
                className="group inline-flex items-center gap-3 bg-stone-900 px-8 py-4 text-sm uppercase tracking-[0.25em] text-stone-50 transition hover:bg-stone-800"
              >
                <span>Read the markets</span>
                <span className="transition-transform group-hover:translate-x-1">→</span>
              </button>
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
      </div>
    </section>
  )
}