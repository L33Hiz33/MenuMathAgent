-- ============================================================
-- Migration: 0001_initial_schema
-- Recipe Advisor v1 schema
--
-- Applied to Supabase production: April 2026 (Saturday)
-- Captured to repo: April 2026 (Saturday evening)
--
-- 27 tables supporting:
--   - Granular ingredient and substitution modeling
--   - Role-based reasoning per recipe
--   - Cross-cultural dish translation via archetypes
--   - Technique-aware substitution (method + equipment + outcomes)
--   - Cuisine and regional availability
--   - Public market data ingestion (USDA, BLS, ERS)
--   - Seasonality patterns per region per month
--   - Provenance tracking (verified vs inferred content)
--   - User correction capture for ontology growth
--
-- Design rationale: see docs/adr/0005-schema-design.md
-- Project segmentation: see docs/adr/0006-project-segmentation.md
--
-- This script is not idempotent. To rerun, drop everything first.
-- ============================================================

-- Ensure UUID generation is available
create extension if not exists "pgcrypto";

-- ============================================================
-- ENUMS
-- Defined once, reused throughout
-- ============================================================

create type provenance_type as enum (
  'human_verified_expert',
  'human_verified_community',
  'human_submitted_unverified',
  'llm_inferred_high_confidence',
  'llm_inferred_low_confidence',
  'imported_from_source',
  'derived_computed'
);

create type complexity_tier as enum (
  'reheat_and_serve',
  'basic_prep',
  'intermediate',
  'advanced',
  'fine_dining'
);

create type role_requirement as enum (
  'required',
  'optional',
  'forbidden',
  'characterizing'
);

create type cost_direction as enum (
  'cheaper',
  'similar',
  'more_expensive',
  'variable'
);

create type substitution_purpose as enum (
  'cost_reduction',
  'quality_improvement',
  'availability_swap',
  'dietary_restriction',
  'technique_simplification',
  'cuisine_translation'
);

create type substitution_kind as enum (
  'ingredient_swap',
  'technique_swap',
  'combined'
);

create type cooking_method_category as enum (
  'dry_heat',
  'moist_heat',
  'combination',
  'fat_based',
  'no_heat',
  'fermentation',
  'preservation'
);

create type equipment_type as enum (
  'vessel',
  'heat_source',
  'tool',
  'appliance'
);

create type technique_difficulty as enum (
  'beginner',
  'intermediate',
  'advanced',
  'expert'
);

create type sensory_sense as enum (
  'sound',
  'smell',
  'sight',
  'touch',
  'taste'
);

create type doneness_stage as enum (
  'starting',
  'progressing',
  'nearly_done',
  'done',
  'overdone'
);

create type flavor_dimension as enum (
  'sweet',
  'salty',
  'sour',
  'bitter',
  'umami',
  'fat',
  'heat',
  'aromatic_intensity'
);

create type adjustment_direction as enum (
  'too_much',
  'too_little'
);

create type market_source_type as enum (
  'usda_terminal',
  'bls_cpi',
  'usda_ers',
  'manual_entry',
  'invoice_extracted'
);

create type update_frequency as enum (
  'daily',
  'weekly',
  'monthly',
  'quarterly',
  'annual'
);

create type inference_source as enum (
  'human_entered',
  'llm_parsed',
  'llm_inferred'
);

create type correction_type as enum (
  'role_inference',
  'substitution_quality',
  'cost_estimate',
  'availability',
  'technique_match',
  'other'
);

create type dish_relationship_type as enum (
  'regional_variant',
  'sauce_variant',
  'protein_variant',
  'technique_variant',
  'cultural_translation',
  'ancestor_descendant'
);

-- ============================================================
-- USERS (stub for v1, real in v2)
-- ============================================================

create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique,
  region_state text,
  region_metro text,
  cuisine_focus text[],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_users_region_state on users(region_state);

-- ============================================================
-- INGREDIENT CATEGORIES (self-referential hierarchy)
-- ============================================================

create table ingredient_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  parent_id uuid references ingredient_categories(id) on delete restrict,
  description text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_ingredient_categories_parent on ingredient_categories(parent_id);

-- ============================================================
-- INGREDIENT ROLES
-- ============================================================

create table ingredient_roles (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- CUISINES (self-referential for hierarchy)
-- ============================================================

create table cuisines (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  parent_id uuid references cuisines(id) on delete restrict,
  region_bias text,
  description text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_cuisines_parent on cuisines(parent_id);

-- ============================================================
-- COOKING METHODS
-- ============================================================

create table cooking_methods (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  category cooking_method_category not null,
  description text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- EQUIPMENT
-- ============================================================

create table equipment (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  equipment_type equipment_type not null,
  thermal_property_notes text,
  max_practical_temp_f integer,
  description text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- TECHNIQUES (composition of method + equipment)
-- ============================================================

create table techniques (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  method_id uuid not null references cooking_methods(id) on delete restrict,
  primary_equipment_id uuid not null references equipment(id) on delete restrict,
  secondary_equipment_id uuid references equipment(id) on delete restrict,
  temperature_range_f text,
  duration_range text,
  difficulty_tier technique_difficulty not null,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_techniques_method on techniques(method_id);
create index idx_techniques_primary_equipment on techniques(primary_equipment_id);

-- ============================================================
-- TECHNIQUE OUTCOMES
-- ============================================================

create table technique_outcomes (
  id uuid primary key default gen_random_uuid(),
  technique_id uuid not null references techniques(id) on delete cascade,
  outcome_name text not null,
  outcome_description text,
  is_signature boolean not null default false,
  achievable_with_alternative_equipment boolean not null default false,
  alternative_notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_technique_outcomes_technique on technique_outcomes(technique_id);

-- ============================================================
-- SENSORY DONENESS CUES
-- ============================================================

create table sensory_doneness_cues (
  id uuid primary key default gen_random_uuid(),
  technique_id uuid not null references techniques(id) on delete cascade,
  sense sensory_sense not null,
  stage doneness_stage not null,
  cue_description text not null,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_sensory_doneness_cues_technique on sensory_doneness_cues(technique_id);

-- ============================================================
-- DISH ARCHETYPES
-- ============================================================

create table dish_archetypes (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- DISH ARCHETYPE COMPONENTS
-- ============================================================

create table dish_archetype_components (
  id uuid primary key default gen_random_uuid(),
  archetype_id uuid not null references dish_archetypes(id) on delete cascade,
  role_id uuid not null references ingredient_roles(id) on delete restrict,
  requirement role_requirement not null,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(archetype_id, role_id)
);

create index idx_dish_archetype_components_archetype on dish_archetype_components(archetype_id);
create index idx_dish_archetype_components_role on dish_archetype_components(role_id);

-- ============================================================
-- INGREDIENTS
-- ============================================================

create table ingredients (
  id uuid primary key default gen_random_uuid(),
  canonical_name text not null unique,
  display_name text not null,
  category_id uuid references ingredient_categories(id) on delete restrict,
  subcategory_id uuid references ingredient_categories(id) on delete restrict,
  default_unit text,
  usda_commodity_code text,
  description text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_ingredients_category on ingredients(category_id);
create index idx_ingredients_subcategory on ingredients(subcategory_id);
create index idx_ingredients_usda_code on ingredients(usda_commodity_code);
create index idx_ingredients_canonical_name on ingredients(canonical_name);

-- ============================================================
-- INGREDIENT ALIASES
-- ============================================================

create table ingredient_aliases (
  id uuid primary key default gen_random_uuid(),
  ingredient_id uuid not null references ingredients(id) on delete cascade,
  alias_name text not null,
  language text,
  region_origin text,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_ingredient_aliases_ingredient on ingredient_aliases(ingredient_id);
create index idx_ingredient_aliases_alias_name on ingredient_aliases(alias_name);

-- ============================================================
-- DISHES
-- ============================================================

create table dishes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  cuisine_id uuid references cuisines(id) on delete restrict,
  archetype_id uuid references dish_archetypes(id) on delete restrict,
  description text,
  complexity_tier complexity_tier not null default 'basic_prep',
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_dishes_cuisine on dishes(cuisine_id);
create index idx_dishes_archetype on dishes(archetype_id);
create index idx_dishes_complexity on dishes(complexity_tier);

-- ============================================================
-- DISH INGREDIENT ROLES
-- ============================================================

create table dish_ingredient_roles (
  id uuid primary key default gen_random_uuid(),
  dish_id uuid not null references dishes(id) on delete cascade,
  role_id uuid not null references ingredient_roles(id) on delete restrict,
  requirement role_requirement not null,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(dish_id, role_id)
);

create index idx_dish_ingredient_roles_dish on dish_ingredient_roles(dish_id);
create index idx_dish_ingredient_roles_role on dish_ingredient_roles(role_id);

-- ============================================================
-- DISH RELATIONSHIPS
-- ============================================================

create table dish_relationships (
  id uuid primary key default gen_random_uuid(),
  dish_a_id uuid not null references dishes(id) on delete cascade,
  dish_b_id uuid not null references dishes(id) on delete cascade,
  relationship_type dish_relationship_type not null,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (dish_a_id <> dish_b_id)
);

create index idx_dish_relationships_a on dish_relationships(dish_a_id);
create index idx_dish_relationships_b on dish_relationships(dish_b_id);

-- ============================================================
-- RECIPES
-- ============================================================

create table recipes (
  id uuid primary key default gen_random_uuid(),
  dish_id uuid references dishes(id) on delete restrict,
  title text not null,
  source text,
  source_url text,
  instructions text,
  yield_quantity numeric,
  yield_unit text,
  complexity_tier complexity_tier,
  submitted_by_user_id uuid references users(id) on delete set null,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_recipes_dish on recipes(dish_id);
create index idx_recipes_user on recipes(submitted_by_user_id);

-- ============================================================
-- RECIPE INGREDIENTS
-- ============================================================

create table recipe_ingredients (
  id uuid primary key default gen_random_uuid(),
  recipe_id uuid not null references recipes(id) on delete cascade,
  ingredient_id uuid not null references ingredients(id) on delete restrict,
  quantity numeric,
  unit text,
  preparation text,
  role_id uuid references ingredient_roles(id) on delete restrict,
  is_optional boolean not null default false,
  notes text,
  inference_source inference_source not null default 'llm_parsed',
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_recipe_ingredients_recipe on recipe_ingredients(recipe_id);
create index idx_recipe_ingredients_ingredient on recipe_ingredients(ingredient_id);
create index idx_recipe_ingredients_role on recipe_ingredients(role_id);

-- ============================================================
-- RECIPE TECHNIQUES
-- ============================================================

create table recipe_techniques (
  id uuid primary key default gen_random_uuid(),
  recipe_id uuid not null references recipes(id) on delete cascade,
  technique_id uuid not null references techniques(id) on delete restrict,
  step_order integer,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_recipe_techniques_recipe on recipe_techniques(recipe_id);
create index idx_recipe_techniques_technique on recipe_techniques(technique_id);

-- ============================================================
-- INGREDIENT TECHNIQUE RESULTS
-- ============================================================

create table ingredient_technique_results (
  id uuid primary key default gen_random_uuid(),
  ingredient_id uuid not null references ingredients(id) on delete cascade,
  technique_id uuid not null references techniques(id) on delete cascade,
  flavor_profile_notes text,
  texture_notes text,
  quality_uplift_score numeric,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(ingredient_id, technique_id),
  check (quality_uplift_score is null or (quality_uplift_score >= 0 and quality_uplift_score <= 1))
);

create index idx_ingredient_technique_results_ingredient on ingredient_technique_results(ingredient_id);
create index idx_ingredient_technique_results_technique on ingredient_technique_results(technique_id);

-- ============================================================
-- SUBSTITUTIONS
-- ============================================================

create table substitutions (
  id uuid primary key default gen_random_uuid(),
  original_ingredient_id uuid not null references ingredients(id) on delete cascade,
  substitute_ingredient_id uuid not null references ingredients(id) on delete cascade,
  role_id uuid references ingredient_roles(id) on delete restrict,
  cuisine_id uuid references cuisines(id) on delete restrict,
  substitution_purpose substitution_purpose not null default 'cost_reduction',
  substitution_kind substitution_kind not null default 'ingredient_swap',
  alternative_technique_id uuid references techniques(id) on delete restrict,
  quality_match_score numeric,
  cost_direction cost_direction not null default 'similar',
  technique_adjustment_notes text,
  notes text,
  verified_by_user_id uuid references users(id) on delete set null,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (quality_match_score is null or (quality_match_score >= 0 and quality_match_score <= 1))
);

create index idx_substitutions_original on substitutions(original_ingredient_id);
create index idx_substitutions_substitute on substitutions(substitute_ingredient_id);
create index idx_substitutions_role on substitutions(role_id);
create index idx_substitutions_purpose on substitutions(substitution_purpose);

-- ============================================================
-- FLAVOR ATTRIBUTES (F1, lightweight per agreement)
-- ============================================================

create table flavor_attributes (
  id uuid primary key default gen_random_uuid(),
  ingredient_id uuid not null references ingredients(id) on delete cascade,
  dimension flavor_dimension not null,
  intensity numeric,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(ingredient_id, dimension),
  check (intensity is null or (intensity >= 0 and intensity <= 10))
);

create index idx_flavor_attributes_ingredient on flavor_attributes(ingredient_id);
create index idx_flavor_attributes_dimension on flavor_attributes(dimension);

-- ============================================================
-- ADJUSTMENT GUIDANCE
-- ============================================================

create table adjustment_guidance (
  id uuid primary key default gen_random_uuid(),
  dimension flavor_dimension not null,
  direction adjustment_direction not null,
  symptoms text not null,
  corrections text not null,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(dimension, direction)
);

-- ============================================================
-- MARKET DATA SOURCES
-- ============================================================

create table market_data_sources (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  source_type market_source_type not null,
  region_code text,
  update_frequency update_frequency not null,
  url text,
  last_fetched_at timestamptz,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_market_data_sources_type on market_data_sources(source_type);
create index idx_market_data_sources_region on market_data_sources(region_code);

-- ============================================================
-- MARKET PRICES
-- ============================================================

create table market_prices (
  id uuid primary key default gen_random_uuid(),
  ingredient_id uuid not null references ingredients(id) on delete cascade,
  source_id uuid not null references market_data_sources(id) on delete restrict,
  region_code text not null,
  price numeric not null,
  unit text not null,
  as_of_date date not null,
  notes text,
  created_at timestamptz not null default now()
);

create index idx_market_prices_ingredient_region_date on market_prices(ingredient_id, region_code, as_of_date desc);
create index idx_market_prices_source on market_prices(source_id);
create index idx_market_prices_date on market_prices(as_of_date desc);

-- ============================================================
-- SEASONALITY PATTERNS
-- ============================================================

create table seasonality_patterns (
  id uuid primary key default gen_random_uuid(),
  ingredient_id uuid not null references ingredients(id) on delete cascade,
  region_code text not null,
  month integer not null,
  availability_score numeric,
  relative_price_index numeric,
  data_years integer,
  notes text,
  provenance provenance_type not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(ingredient_id, region_code, month),
  check (month >= 1 and month <= 12),
  check (availability_score is null or (availability_score >= 0 and availability_score <= 1))
);

create index idx_seasonality_ingredient_region on seasonality_patterns(ingredient_id, region_code);

-- ============================================================
-- USER CORRECTIONS
-- ============================================================

create table user_corrections (
  id uuid primary key default gen_random_uuid(),
  user_session_id text,
  user_id uuid references users(id) on delete set null,
  recipe_id uuid references recipes(id) on delete set null,
  correction_type correction_type not null,
  original_value jsonb,
  corrected_value jsonb,
  notes text,
  reviewed boolean not null default false,
  incorporated boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_user_corrections_session on user_corrections(user_session_id);
create index idx_user_corrections_user on user_corrections(user_id);
create index idx_user_corrections_type on user_corrections(correction_type);
create index idx_user_corrections_reviewed on user_corrections(reviewed) where reviewed = false;

-- ============================================================
-- UPDATED_AT TRIGGER
-- Automatically maintains updated_at on every row update.
-- Applied to all tables that have updated_at columns.
-- ============================================================

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Attach trigger to all tables with updated_at
do $$
declare
  t text;
begin
  for t in
    select table_name
    from information_schema.columns
    where table_schema = 'public'
      and column_name = 'updated_at'
  loop
    execute format('
      create trigger trg_set_updated_at_%I
      before update on %I
      for each row
      execute function set_updated_at();
    ', t, t);
  end loop;
end;
$$;

-- ============================================================
-- DONE
-- 27 tables, indexes, foreign keys, constraints, triggers.
-- ============================================================
