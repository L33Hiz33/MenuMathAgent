-- ============================================================
-- Migration: 0003_recipe_sub_recipes_and_pairings
-- DDL only. Zero INSERT statements.
--
-- Adds two tables absent from the initial schema:
--   1. recipe_sub_recipes: a recipe can include another
--      recipe as a structural component (stock, duxelles,
--      pastry cream, dressing, etc.).
--   2. dish_pairings: companion dishes that complete a
--      primary dish at service.
--
-- Design rationale: docs/risks.md "Schema gaps from stress testing"
-- Specs: docs/status.md Saturday session, Lee's decisions 2026-04-26
--
-- Applied to Supabase production: 2026-04-27
-- ============================================================

-- ============================================================
-- NEW ENUM: pairing_popularity_tier
-- ============================================================

create type pairing_popularity_tier as enum (
  'universal',
  'regional',
  'insider_knowledge',
  'innovative'
);

-- ============================================================
-- recipe_sub_recipes
--
-- A sub-recipe reference means the child recipe IS the
-- component. It replaces (not supplements) the corresponding
-- recipe_ingredients row. Do not create both for the same
-- component.
--
-- role_id captures what role the sub-recipe plays in the
-- parent, enabling substitution at the recipe-component level
-- (e.g., swap this stock recipe for another liquid_base).
--
-- The runtime traverses sub-recipes for cost aggregation.
-- Cycle prevention (A -> B -> A) is enforced in application
-- code; a CHECK constraint cannot catch multi-hop cycles.
-- ============================================================

create table recipe_sub_recipes (
  id               uuid primary key default gen_random_uuid(),
  parent_recipe_id uuid not null references recipes(id) on delete cascade,
  sub_recipe_id    uuid not null references recipes(id) on delete restrict,
  role_id          uuid references ingredient_roles(id) on delete restrict,
  quantity         numeric,
  unit             text,
  step_order       integer,
  is_optional      boolean not null default false,
  notes            text,
  provenance       provenance_type not null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (parent_recipe_id, sub_recipe_id),
  check (parent_recipe_id <> sub_recipe_id)
);

create index idx_recipe_sub_recipes_parent on recipe_sub_recipes(parent_recipe_id);
create index idx_recipe_sub_recipes_sub    on recipe_sub_recipes(sub_recipe_id);
create index idx_recipe_sub_recipes_role   on recipe_sub_recipes(role_id);

-- ============================================================
-- dish_pairings
--
-- Directional: primary_dish_id is the dish being served,
-- paired_dish_id is the companion.
--
-- contrast_dimensions is a text array of the flavor or
-- sensory axes where the pairing creates productive contrast
-- (e.g., ARRAY['acid', 'fat', 'temperature', 'texture']).
-- No controlled vocabulary enforced here; values emerge from
-- seed content and can be standardized later.
-- ============================================================

create table dish_pairings (
  id                  uuid primary key default gen_random_uuid(),
  primary_dish_id     uuid not null references dishes(id) on delete cascade,
  paired_dish_id      uuid not null references dishes(id) on delete cascade,
  contrast_dimensions text[],
  synergy_notes       text,
  popularity_tier     pairing_popularity_tier not null,
  notes               text,
  provenance          provenance_type not null,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (primary_dish_id, paired_dish_id),
  check (primary_dish_id <> paired_dish_id)
);

create index idx_dish_pairings_primary on dish_pairings(primary_dish_id);
create index idx_dish_pairings_paired  on dish_pairings(paired_dish_id);

-- ============================================================
-- UPDATED_AT TRIGGERS
-- The dynamic block in 0001 cannot be rerun without creating
-- duplicate triggers on existing tables. Attach manually.
-- ============================================================

create trigger trg_set_updated_at_recipe_sub_recipes
  before update on recipe_sub_recipes
  for each row execute function set_updated_at();

create trigger trg_set_updated_at_dish_pairings
  before update on dish_pairings
  for each row execute function set_updated_at();

-- ============================================================
-- DONE
-- 2 new tables, 5 new indexes, 1 new enum, 2 new triggers.
-- Total table count: 29.
-- ============================================================
