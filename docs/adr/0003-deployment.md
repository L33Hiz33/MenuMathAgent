# ADR 0003: Deployment

Status: Draft
Date: April 2026

## Context

The product needs a public URL by end of week. We have decisions to make about:

- Front-end hosting
- Backend or serverless function hosting
- Database (already chosen: Supabase)
- Domain (use a free subdomain or buy a domain)

## Decision

For v1:

1. **Front-end:** Vercel. Free tier is sufficient. Excellent DX, instant deploys from Git, automatic HTTPS, edge network.

2. **Backend reasoning logic:** Vercel Serverless Functions or Supabase Edge Functions. Decision deferred until front-end framework is chosen, but both are acceptable. Both can call out to the LLM provider and to Supabase.

3. **Database:** Supabase (already chosen, schema deployed).

4. **Domain:** Use Vercel's free `.vercel.app` subdomain for v1. If the project has legs after v1, register a real domain via Cloudflare or Namecheap (~12 USD/year).

5. **Environment management:** All credentials (Supabase service role key, LLM API key) live in Vercel environment variables. Never committed to the repo. Front-end code uses Supabase anon key only and respects RLS.

6. **Row Level Security:** Enable RLS on Supabase tables. Anonymous users can read most reference data but cannot write directly to anything except `user_corrections`. The reasoning engine writes via service role key from the backend.

## Consequences

**Positive:**
- Free for v1. Probably free for the first 100+ users.
- One-command deploys from Git push.
- Global CDN, fast load.
- Standard, well-documented stack.

**Negative:**
- Vercel cold starts on serverless functions are real. Could add 1 to 2 seconds to first request.
- Vendor lock-in is moderate. Migration off Vercel is doable but not trivial.
- Free tier has limits. If usage spikes, we need to upgrade.

**Mitigation:**
- For cold starts: keep functions warm with a lightweight ping if it becomes an issue. Probably not a v1 concern.
- For lock-in: front-end code is just Next.js or similar standard React, portable to Netlify or self-hosted.

## Alternatives considered

**Self-host on a VPS.** Rejected. Too much DevOps overhead for one week.

**Netlify instead of Vercel.** Acceptable alternative, very similar feature set. Vercel chosen for slightly better Next.js integration if we go that route.

**Cloudflare Pages + Workers.** Acceptable alternative. Considered briefly. Vercel is more familiar to most JavaScript developers and Lee will likely have less friction there.

**Buy a domain immediately.** Deferred. The Vercel subdomain is fine for the v1 demo. Buying a domain is a 30 minute task whenever we want to do it.

## Open questions

- Front-end framework: Next.js, vanilla React, SvelteKit, or something else? Decision deferred to first day of build, will be made based on Lee's preference and what gets him to a working UI fastest.
- Whether the reasoning engine runs as Vercel functions or as a separate Node service. Decision deferred. Vercel functions are simpler if cold starts are tolerable.
