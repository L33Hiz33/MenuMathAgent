# ADR 0004: LLM Provider

Status: Draft
Date: April 2026

## Context

The product depends on LLM calls for:

- Recipe parsing (structured output)
- Ingredient role inference
- Substitution reasoning and explanation generation
- Output narrative generation
- Build-time content generation for the Ingredient Knowledge Agent

We need a provider that handles structured output well, has reasonable latency, and is cost-effective at v1 scale.

## Decision

For v1, use Claude via the Anthropic API. Specifically, the latest Sonnet model for runtime calls and possibly Opus for the Ingredient Knowledge Agent's higher-stakes content generation.

Reasoning:
- Lee is already familiar with Claude through Claude Code and the chat product
- Anthropic API supports structured output via tool use with reliable JSON
- Claude is strong at the kind of contextual reasoning needed for ingredient role inference
- Pricing is competitive and predictable

## Consequences

**Positive:**
- Single provider, single API key to manage
- Strong general capability across all tasks needed
- Good documentation and SDK support

**Negative:**
- Vendor lock-in. Migrating to OpenAI or Gemini would require prompt rewrites.
- API rate limits at v1 scale unlikely to be a problem. At v1.1 with users, may matter.

**Mitigation:**
- Abstract LLM calls behind a thin internal interface so swapping providers is a matter of changing one module.
- Track per-request cost so we can model future scale.

## Alternatives considered

**OpenAI GPT-4 family.** Acceptable. Comparable capability. Default choice for many developers. Chosen Claude because of Lee's existing familiarity and Anthropic's strength in structured reasoning.

**Google Gemini.** Acceptable. Long context window is attractive but not currently needed at v1 scale.

**Open-source local models.** Rejected for v1. Operationally heavier, would distract from shipping. Possibly worth revisiting in v2 for cost reduction at scale.

**Multiple providers in parallel.** Rejected. Adds complexity for marginal benefit. Pick one and ship.

## Open questions

- Which exact Claude model for runtime: Sonnet 4.6, Opus 4.6, Opus 4.7, Haiku 4.5? Decision deferred to first build session. Likely Sonnet for cost-performance, Haiku for parsing if quality is sufficient, Opus for build-time content generation where quality matters most.
- Whether to use prompt caching aggressively for the system prompt. Worth doing if it provides meaningful cost reduction.
