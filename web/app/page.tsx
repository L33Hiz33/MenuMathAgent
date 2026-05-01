export default function Home() {
  return (
    <div
      className="relative flex min-h-screen flex-col bg-[#f5f0e8] text-stone-900"
      style={{ fontFamily: "var(--font-inter), system-ui, sans-serif" }}
    >
      {/* Subtle paper grain texture */}
      <div
        className="pointer-events-none absolute inset-0 opacity-[0.35] mix-blend-multiply"
        style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='2' stitchTiles='stitch'/%3E%3CfeColorMatrix values='0 0 0 0 0.4 0 0 0 0 0.3 0 0 0 0 0.2 0 0 0 0.08 0'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E")`,
        }}
      />

      {/* Top hairline */}
      <div className="relative z-10 mx-auto w-full max-w-6xl px-8 pt-8">
        <div className="h-px w-full bg-stone-900/20" />
      </div>

      {/* Top masthead */}
      <header className="relative z-10 mx-auto w-full max-w-6xl px-8 pt-4">
        <div className="flex items-center justify-between text-[11px] uppercase tracking-[0.25em] text-stone-600">
          <span>Volume 01 &nbsp;·&nbsp; Issue 01</span>
          <span className="hidden sm:block">Houston, Texas</span>
          <span>Spring 2026</span>
        </div>
      </header>

      {/* Main editorial layout */}
      <main className="relative z-10 mx-auto flex w-full max-w-6xl flex-1 flex-col justify-center px-8 py-20">
        <div className="grid grid-cols-12 gap-8">
          {/* Left column: kicker + headline + deck */}
          <div className="col-span-12 md:col-span-8">
            <div className="mb-6 flex items-center gap-3">
              <span className="h-px w-8 bg-stone-900" />
              <span className="text-[11px] uppercase tracking-[0.3em] text-stone-700">
                A working tool for kitchens
              </span>
            </div>

            <h1
              className="mb-8 leading-[0.95] tracking-tight text-stone-900"
              style={{
                fontFamily: "var(--font-playfair), Georgia, serif",
                fontSize: "clamp(3rem, 9vw, 7rem)",
                fontWeight: 800,
              }}
            >
              Menu
              <br />
              <span className="italic font-medium text-stone-800">Math</span>
              {" "}
              Agent
            </h1>

            <p
              className="mb-6 max-w-xl text-2xl leading-snug text-stone-700 sm:text-3xl"
              style={{ fontFamily: "var(--font-playfair), Georgia, serif" }}
            >
              Real cooking. Real markets. Real substitutions.
            </p>

            <p className="max-w-lg text-base leading-relaxed text-stone-600">
              Not a chatbot. Not a recipe generator. A working advisor that reads
              the food economy and tells you what to do about it.
            </p>
          </div>

          {/* Right column: status card */}
          <aside className="col-span-12 md:col-span-4">
            <div className="border border-stone-900/15 bg-stone-50/40 p-6 backdrop-blur-sm">
              <div className="mb-4 flex items-center gap-2">
                <span className="inline-block h-1.5 w-1.5 animate-pulse rounded-full bg-amber-700" />
                <span className="text-[10px] uppercase tracking-[0.25em] text-stone-700">
                  In development
                </span>
              </div>

              <p
                className="mb-4 text-lg leading-snug text-stone-800"
                style={{
                  fontFamily: "var(--font-playfair), Georgia, serif",
                  fontStyle: "italic",
                }}
              >
                "Decades of culinary intelligence and live market data, working
                your menu while you sleep."
              </p>

              <div className="border-t border-stone-900/15 pt-4">
                <div className="grid grid-cols-2 gap-4 text-xs">
                  <div>
                    <div className="mb-1 text-[10px] uppercase tracking-[0.2em] text-stone-500">
                      Dishes
                    </div>
                    <div
                      className="text-2xl text-stone-900"
                      style={{
                        fontFamily: "var(--font-playfair), Georgia, serif",
                        fontWeight: 700,
                      }}
                    >
                      8
                    </div>
                  </div>
                  <div>
                    <div className="mb-1 text-[10px] uppercase tracking-[0.2em] text-stone-500">
                      Cuisines
                    </div>
                    <div
                      className="text-2xl text-stone-900"
                      style={{
                        fontFamily: "var(--font-playfair), Georgia, serif",
                        fontWeight: 700,
                      }}
                    >
                      7
                    </div>
                  </div>
                  <div>
                    <div className="mb-1 text-[10px] uppercase tracking-[0.2em] text-stone-500">
                      Substitutions
                    </div>
                    <div
                      className="text-2xl text-stone-900"
                      style={{
                        fontFamily: "var(--font-playfair), Georgia, serif",
                        fontWeight: 700,
                      }}
                    >
                      81
                    </div>
                  </div>
                  <div>
                    <div className="mb-1 text-[10px] uppercase tracking-[0.2em] text-stone-500">
                      Engine
                    </div>
                    <div
                      className="text-2xl text-stone-900"
                      style={{
                        fontFamily: "var(--font-playfair), Georgia, serif",
                        fontWeight: 700,
                      }}
                    >
                      v1.2
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </aside>
        </div>
      </main>

      {/* Bottom masthead */}
      <footer className="relative z-10 mx-auto w-full max-w-6xl px-8 pb-8">
        <div className="mb-3 h-px w-full bg-stone-900/20" />
        <div className="flex items-center justify-between text-[11px] uppercase tracking-[0.25em] text-stone-600">
          <span>menumathagent.com</span>
          <span className="hidden sm:block">By Lee Hisey</span>
          <span>Phase 1 of 8</span>
        </div>
      </footer>
    </div>
  );
}