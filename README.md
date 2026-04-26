# Recipe Advisor

## What it is

A tool that takes a recipe, evaluates its ingredients in context, and returns substitution suggestions that lower cost or improve quality without changing what the cook is trying to make. Substitutions are grounded in current public market data (USDA terminal reports, BLS food CPI, USDA ERS outlook), regional availability, and seasonality. The tool tells the operator what is happening in the food economy right now and how to adjust accordingly.

## Who it is for

Food truck operators. Skill range is intentionally unbounded, from a basic taco truck to a chef running a Michelin-aspirational pop-up. The tool infers sophistication from the recipe input rather than asking the user to declare a tier.

## What it does in v1

A user pastes a recipe in freeform text and declares their location (state or metro). The tool parses the recipe into ingredients with quantities, and infers each ingredient's role in the dish (structural flavor base, primary protein, acid component, garnish, binding agent, etc.). For each ingredient, it pulls current market signals from public data sources keyed to the user's regional terminal market, and factors in regional availability for ingredients with strong geographic bias. It returns:

- Market context for the recipe right now, including which ingredients are seasonally favorable, which are expensive relative to history, and which are trending up or down
- Substitution suggestions ranked by cost impact and role fidelity, with the inferred role and substitution reasoning shown to the user so they can correct or override
- Regional availability flags for substitutions that may not be easy to source in the user's area
- An honest assessment of whether this is a good week to make the dish

Every cost claim is tied to a public source. Substitutions are framed as relative or directional, except where USDA wholesale data gives a real number. Regional availability is flagged with explicit uncertainty rather than asserted.

The tool defaults to cost-reduction substitutions. If asked, it can also suggest quality-improvement substitutions ("upgrade mode") and consider technique changes that improve the dish without changing ingredients.

## What v1.1 adds

An ingredient-level 12-month seasonality view per region. For any ingredient, show historical patterns of price and availability across the year, with explicit uncertainty disclosure for forecasts beyond three months. Forecasts beyond three months are labeled as historical-pattern-based, with visible callouts for factors that could move them: weather, tariffs, regulatory changes, supply chain disruption.

Ingredient-centric, not menu-centric. The user decides what to do with their menu. The tool surfaces patterns.

## What this is not

- Not a recipe builder
- Not an ordering platform or supplier marketplace
- Not a meal planner or grocery list generator
- Not a nutrition tracker
- Not a confident price forecaster beyond the near term
- Not, in v1, integrated with invoice or POS data. Invoice ingestion is v2.

## 30-day success

- Working tool standing up at a public URL with at least one real public data source connected
- 5 to 10 food truck operators have used the tool at least once and given feedback
- Toast interview secured or scheduled, with this product as the demo artifact

## Build constraint, this week

A viable, designed MVP standing up by end of week. Definition of viable: a real user can paste a real recipe and their location, the tool returns a real substitution advisory grounded in at least one real public data source, with ingredient role inference shown and regional context factored in. Not a landing page. Not a vaporware mockup. A working demo with honest data.

Working budget: approximately 24 focused hours across the week.

## What is being explicitly deferred

Everything not on the v1 list. Including but not limited to: invoice parsing, supplier integrations, user accounts, saved recipes, history, sharing, mobile app, multi-user features, retail grocery pricing, recipe builder, meal planning, nutrition data, calendar UI, account settings, full role ontology beyond the curated starter set, full regional availability database beyond a curated short list.

The discipline is: if a feature is not on the v1 list, it does not get built this week, regardless of how easy it sounds. v1.1 starts after v1 ships.

## See also

- `CLAUDE.md` for project context Claude Code reads each session
- `docs/spec-v1.md` for v1 behavior spec
- `docs/adr/` for architecture decisions
- `docs/milestones.md` for milestone breakdown
- `docs/risks.md` for open risks
