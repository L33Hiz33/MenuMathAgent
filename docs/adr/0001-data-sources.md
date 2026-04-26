# ADR 0001: Data Sources

Status: Accepted
Date: April 2026

## Context

The product needs ingredient pricing and seasonality data to make substitution recommendations grounded in market reality. We do not have access to wholesale supplier pricing (Sysco, US Foods, PFG) and cannot legally or operationally scrape retail grocery sites at scale. We have to build on public data only, at least in v1.

## Decision

For v1, we use the following public sources:

1. **USDA AMS Terminal Market Reports.** Primary source for wholesale produce and meat pricing. Regional (Atlanta, Boston, Chicago, Dallas, LA, New York, others). Free, structured, daily-to-weekly updates.

2. **BLS Consumer Price Index, food categories.** Monthly. Provides directional trend (up or down YoY) on broad food categories.

3. **USDA ERS Food Price Outlook.** Forward-looking forecasts on food category trends. Used for "what's coming" signaling.

4. **Seasonality data.** Captured in our own `seasonality_patterns` table, derived from historical market_prices over time. v1 starts with hand-curated seasonality patterns for the most common food truck ingredients. Augmented over time as market_prices accumulates history.

For v2, the path is:

5. Invoice ingestion. User uploads or syncs invoices. We parse them and write to `market_prices` with `source_type = invoice_extracted`.

For absolute retail pricing: out of scope. We do not assert "chicken costs $4.99 at your store." We work in relative spreads, directional movement, and wholesale-grounded pricing.

## Consequences

**Positive:**
- Honest by default. We do not invent prices we do not have.
- Public data is free and stable.
- Schema accommodates v2 invoice ingestion without redesign.
- Users with no invoice data still get useful output.

**Negative:**
- USDA terminal market data is messy. Parser will be a real engineering problem.
- We cannot give a food truck operator their actual plate cost. We can give them market context.
- Some ingredients (specialty items, branded products, anything not in USDA categories) will have no pricing data.

**Mitigation:**
- Be explicit in UI about what data backs each claim.
- Prioritize the 50 to 100 most common food truck ingredients for pricing coverage.
- For ingredients without data, fall back to seasonality patterns and LLM reasoning, with appropriate uncertainty disclosure.

## Alternatives considered

**Scrape grocery retail sites.** Rejected. Legally and operationally fragile. Most ToS prohibit it. Even if we ignored that, the data is not what food truck operators actually buy on.

**Pay for a wholesale data feed.** None exists publicly. Sysco's pricing is private to their customers.

**Crowdsource pricing from users.** Considered for v2. Out of scope for v1 because we have no users yet.

**Use only seasonality, ignore current pricing.** Considered. Rejected because point-in-time market signals are a real differentiator. Seasonality alone is too generic.
