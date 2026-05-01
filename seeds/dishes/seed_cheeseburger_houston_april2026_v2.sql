-- ============================================================
-- Seed: American cheeseburger (classic diner-style, Houston metro, April 2026)
-- v2 CORRECTED: dish complexity_tier 'beginner' was invalid enum value.
-- Fixed to 'basic_prep'. Valid enum values: reheat_and_serve, basic_prep,
-- intermediate, advanced, fine_dining.
--
-- Provenance for ALL rows: llm_inferred_low_confidence
-- All inserts in a single transaction.
-- ============================================================

BEGIN;

-- ============================================================
-- EQUIPMENT (6 new rows)
-- ============================================================

INSERT INTO equipment (id, name, equipment_type, thermal_property_notes, max_practical_temp_f, description, provenance) VALUES
  (gen_random_uuid(), 'griddle_flat_top', 'heat_source', 'Commercial flat-top griddle; gas or electric heated steel surface.', 600, 'Flat-top griddle for diner-style burger cooking; ideal for smashburger and bun toasting.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'cast_iron_pan_heavy', 'vessel', 'Heavy cast iron retains and conducts high heat well.', 700, 'Heavy cast iron pan for home or food truck without commercial griddle.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'burger_press_or_smasher', 'tool', NULL, NULL, 'Heavy flat tool for smashburger technique; presses ball of beef flat onto hot surface.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'spatula_metal', 'tool', NULL, NULL, 'Thin sharp metal spatula for flipping patties and lifting bun crust.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'cloche_or_pan_lid_for_melt', 'tool', 'Traps steam and heat over patty for cheese melt acceleration.', NULL, 'Dome cloche or pan lid covering patty during cheese melt.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'meat_thermometer', 'tool', NULL, NULL, 'Probe thermometer for safe cooking of thicker patties or non-beef proteins.', 'llm_inferred_low_confidence');

-- ============================================================
-- TECHNIQUES (12 new rows)
-- ============================================================

INSERT INTO techniques (id, name, method_id, primary_equipment_id, secondary_equipment_id, temperature_range_f, duration_range, difficulty_tier, notes, provenance)
SELECT gen_random_uuid(), t.name, cm.id, eq1.id, eq2.id, t.temp, t.duration, t.difficulty::technique_difficulty, t.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('assembly_layered_burger', 'no_heat', 'mixing_bowl', NULL::text, NULL::text, '1 min', 'beginner', 'Assemble in order: bottom bun, condiments, lettuce, patty+cheese, tomato, onion, pickles, top bun. Lettuce-on-bottom prevents tomato juice soaking bun.'),
  ('form_patty_loose_no_packing', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'beginner', 'Handle ground beef minimally. Over-packed patty becomes dense and rubbery. Form gently into puck shape, leave loose.'),
  ('form_patty_smashed_method', 'dry_heat', 'burger_press_or_smasher', 'griddle_flat_top', '450-500', '90 sec total', 'intermediate', 'Place ball of beef on hot surface. Smash flat with press for 10 sec. Cook 60-90 sec. Develops dramatic Maillard crust. Smashburger style.'),
  ('season_immediately_before_cook', 'no_heat', 'mixing_bowl', NULL, NULL, '5 sec', 'beginner', 'Salt and pepper applied seconds before patty hits heat. Salting in advance dissolves myosin proteins and creates dense rubbery sausage texture, NOT a juicy burger.'),
  ('cook_high_heat_dry_or_griddle_3_to_4min_per_side_for_medium', 'dry_heat', 'griddle_flat_top', 'cast_iron_pan_heavy', '400-500', '6-8 min total', 'beginner', 'Do NOT press patty during cook. Pressing squeezes out juices. Cook 3-4 min per side for medium doneness on 4-6 oz patty.'),
  ('rest_briefly_before_assembly_2min', 'no_heat', 'mixing_bowl', NULL, NULL, '2 min', 'beginner', 'Brief rest allows juices to redistribute. Do not over-rest or patty cools.'),
  ('toast_bun_buttered_face_down_on_griddle_30_to_60sec', 'dry_heat', 'griddle_flat_top', NULL, '350-400', '30-60 sec', 'beginner', 'Butter cut faces of bun. Toast face-down on griddle until golden brown. THE detail separating diner-quality burger from amateur burger. Untoasted bun absorbs juice and falls apart.'),
  ('place_cheese_on_patty_30sec_before_pull_from_heat', 'no_heat', 'cloche_or_pan_lid_for_melt', NULL, NULL, '30-60 sec', 'beginner', 'Place cheese slice on patty 30 sec before pull from heat. Cover with cloche or pan lid to trap steam and heat for accelerated melt. American cheese melts in 30 sec; cheddar needs 60+ sec and may still break.'),
  ('spread_condiment_on_bun_face', 'no_heat', 'mixing_bowl', NULL, NULL, '10 sec', 'beginner', 'Apply mayo, ketchup, or mustard to toasted bun face. Mayo on top bun, ketchup on bottom bun is classic diner pattern.'),
  ('slice_tomato_thick_round', 'no_heat', 'chef_knife', NULL, NULL, '30 sec', 'beginner', 'Slice tomato into thick (1/4 inch) round. Thinner slices add no flavor; thicker slices unbalance the burger.'),
  ('slice_onion_thin_rings', 'no_heat', 'chef_knife', NULL, NULL, '30 sec', 'beginner', 'Slice onion into thin rings. White or yellow onion is classic diner default; red is sharper alternative.'),
  ('assemble_in_order_bottom_to_top', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'beginner', 'Bottom bun (toasted), condiment, lettuce (acts as moisture barrier), patty with cheese, tomato, onion, pickles, top bun (toasted) with condiment. Lettuce-as-moisture-barrier is real diner technique.')
) AS t(name, method_name, primary_eq_name, secondary_eq_name, temp, duration, difficulty, notes)
JOIN cooking_methods cm ON cm.name = t.method_name
JOIN equipment eq1 ON eq1.name = t.primary_eq_name
LEFT JOIN equipment eq2 ON eq2.name = t.secondary_eq_name;

-- ============================================================
-- CUISINE (1 new row)
-- ============================================================

INSERT INTO cuisines (id, name, parent_id, region_bias, description, provenance) VALUES
  (gen_random_uuid(), 'American', NULL, 'United States', 'American cuisine, encompassing strong regional sub-traditions: Northeast diner, Texas/Southwest, California, Southern, Midwest, Pacific Northwest. Includes classic American comfort foods and regional fusions.', 'llm_inferred_low_confidence');

-- ============================================================
-- INGREDIENTS (~22 new rows)
-- ============================================================

INSERT INTO ingredients (id, canonical_name, display_name, category_id, subcategory_id, default_unit, usda_commodity_code, description, provenance)
SELECT gen_random_uuid(), i.canonical_name, i.display_name, cat.id, NULL, i.default_unit, NULL, i.description, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('ground_beef_80_20_chuck', 'Ground beef, 80/20, chuck', 'proteins', 'g', 'Ground chuck cut at 80% lean / 20% fat ratio. Classic American burger default. Industry-standard fat ratio for juicy burgers.'),
  ('ground_beef_chuck_brisket_blend_60_40', 'Ground beef, chuck-brisket blend (60/40 chuck-to-brisket)', 'proteins', 'g', 'Custom-ground blend of chuck and brisket cuts. Premium burger standard. Brisket adds rich beefy umami; chuck provides ideal fat distribution.'),
  ('ground_beef_90_10_lean', 'Ground beef, 90/10, lean', 'proteins', 'g', 'Ground beef at 90% lean / 10% fat. Lower fat content yields drier burger. Substitute for dietary preference, not flavor.'),
  ('ground_beef_pre_ground_supermarket_unspecified', 'Ground beef, pre-ground, supermarket (unspecified cut)', 'proteins', 'g', 'Pre-ground "ground beef" without cut specification. Usually trim mix of unknown cuts. Lower quality default at most grocery stores.'),
  ('ground_turkey', 'Ground turkey', 'proteins', 'g', 'Ground turkey breast and/or thigh meat. Substitute protein for cheeseburger; produces different product (turkey burger).'),
  ('plant_based_patty_beyond_or_impossible', 'Plant-based patty (Beyond or Impossible)', 'proteins', 'g', 'Pre-formed plant-based burger patty designed to mimic ground beef. Vegetarian/vegan substitute.'),
  ('bacon_thick_cut', 'Bacon, thick-cut', 'proteins', 'g', 'Thick-cut smoked pork belly bacon. Optional addition to cheeseburger.'),
  ('eggs_large_for_burger_topping', 'Eggs, large (for burger topping)', 'dairy', 'each', 'Large fresh eggs for fried-egg-on-burger optional addition (Australian/regional variant).'),
  ('american_cheese_single_slice', 'American cheese, single slice', 'dairy', 'g', 'Yellow processed American cheese slice (Kraft Singles, Land O''Lakes deli, etc.). Sodium citrate emulsifier produces smooth even melt without breaking. Diner-canonical for cheeseburger.'),
  ('cheddar_aged', 'Cheddar, aged', 'dairy', 'g', 'Aged natural cheddar cheese. Substitute for American cheese; breaks into oil-and-curd separation when melted on hot patty (lacks sodium citrate emulsifiers).'),
  ('pepper_jack', 'Pepper jack cheese', 'dairy', 'g', 'Monterey jack with peppers. Tex-Mex regional variant for cheeseburger.'),
  ('bun_soft_white_sesame_top_classic', 'Bun, soft white, sesame top (classic American diner)', 'pantry', 'g', 'Pre-made soft white burger bun with sesame seeds on top. Industry default for classic diner cheeseburger.'),
  ('bun_brioche', 'Bun, brioche', 'pantry', 'g', 'Pre-made enriched egg-and-butter brioche bun. Premium substitute; dissolves faster in juice than soft white.'),
  ('bun_pretzel', 'Bun, pretzel', 'pantry', 'g', 'Pre-made alkaline pretzel-style bun. Distinctive savory crust. Brewpub variant.'),
  ('bun_potato_roll_martins', 'Bun, potato roll (Martin''s or equivalent)', 'pantry', 'g', 'Soft potato-flour roll. Modern higher-quality default at many burger operations.'),
  ('lettuce_iceberg', 'Lettuce, iceberg', 'vegetables', 'g', 'Iceberg lettuce. Crisp crunch. Classic diner default for cheeseburger.'),
  ('lettuce_butter_bibb', 'Lettuce, butter (Bibb)', 'vegetables', 'g', 'Butter or Bibb lettuce. Softer texture than iceberg. Modern preference for elevated burger.'),
  ('tomato_beefsteak_slicing', 'Tomato, beefsteak (slicing variety)', 'vegetables', 'g', 'Large beefsteak tomato for slicing. Quality varies dramatically by season.'),
  ('onion_white_or_yellow_raw_thin_sliced', 'Onion, white or yellow, raw, thin-sliced', 'vegetables', 'g', 'Raw onion in thin rings. White or yellow standard for classic diner; red is sharper alternative.'),
  ('avocado_sliced', 'Avocado, sliced', 'vegetables', 'g', 'Fresh sliced avocado. Optional California regional variant for cheeseburger.'),
  ('pickles_dill_chips_kosher', 'Pickles, dill chips (kosher)', 'sauces_and_condiments', 'g', 'Kosher dill pickle chips. Diner-canonical pickle for cheeseburger.'),
  ('mayonnaise', 'Mayonnaise', 'sauces_and_condiments', 'g', 'Standard mayonnaise. Applied to top bun face after toasting.'),
  ('ketchup_heinz_or_hunts', 'Ketchup (Heinz or Hunt''s)', 'sauces_and_condiments', 'g', 'Standard American ketchup. Applied to bottom bun or top of patty.'),
  ('yellow_mustard_frenchs', 'Yellow mustard (French''s)', 'sauces_and_condiments', 'g', 'Standard American yellow mustard. Optional condiment for cheeseburger.')
) AS i(canonical_name, display_name, category_name, default_unit, description)
JOIN ingredient_categories cat ON cat.name = i.category_name;

-- ============================================================
-- INGREDIENT ALIASES
-- ============================================================

INSERT INTO ingredient_aliases (id, ingredient_id, alias_name, language, region_origin, notes, provenance)
SELECT gen_random_uuid(), ing.id, a.alias_name, a.language, a.region_origin, a.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('ground_beef_80_20_chuck', 'ground chuck', 'en', 'US', 'Common name for chuck-cut ground beef.'),
  ('ground_beef_80_20_chuck', '80/20 ground beef', 'en', 'US', 'Common fat-ratio designation.'),
  ('ground_beef_chuck_brisket_blend_60_40', 'butcher blend', 'en', 'US', 'Generic name for premium custom-ground beef.'),
  ('american_cheese_single_slice', 'Kraft Singles', 'en', 'US', 'Common brand often used as generic.'),
  ('american_cheese_single_slice', 'processed cheese slice', 'en', 'US', 'Functional description.'),
  ('lettuce_butter_bibb', 'Boston lettuce', 'en', 'US', 'Common alternate name for butter/Bibb lettuce.'),
  ('lettuce_butter_bibb', 'bib lettuce', 'en', 'US', 'Common misspelling/variant.'),
  ('tomato_beefsteak_slicing', 'slicing tomato', 'en', 'US', 'Generic description of large round tomatoes for sandwiches and burgers.'),
  ('bun_potato_roll_martins', 'Martins potato roll', 'en', 'US', 'Brand name without apostrophe; common reference.'),
  ('plant_based_patty_beyond_or_impossible', 'Beyond Burger', 'en', 'US', 'Specific brand variant of plant-based patty.'),
  ('plant_based_patty_beyond_or_impossible', 'Impossible Burger', 'en', 'US', 'Specific brand variant of plant-based patty.')
) AS a(canonical_name, alias_name, language, region_origin, notes)
JOIN ingredients ing ON ing.canonical_name = a.canonical_name;

-- ============================================================
-- DISH (1 new row) -- FIXED: 'beginner' -> 'basic_prep'
-- ============================================================

INSERT INTO dishes (id, name, cuisine_id, archetype_id, description, complexity_tier, provenance)
SELECT gen_random_uuid(), 'American cheeseburger (classic diner-style)', c.id, NULL,
  'Classic American diner-style cheeseburger. Single 4-6 oz beef patty (80/20 ground chuck or chuck-brisket blend), American cheese, lettuce, tomato, raw onion, pickle, condiments (mayo, ketchup, yellow mustard) on toasted soft white bun. Deceptively simple; quality of beef grind, bun toasting technique, and cheese melt timing dominate outcome. Regional variants include smashburger, California-style with avocado, Tex-Mex with pepper jack/jalapeño, and gastropub variants.',
  'basic_prep'::complexity_tier, 'llm_inferred_low_confidence'::provenance_type
FROM cuisines c WHERE c.name = 'American';

-- ============================================================
-- RECIPES (5 rows: 1 parent + 4 sub-recipes) -- FIXED: 'beginner' -> 'basic_prep'
-- ============================================================

INSERT INTO recipes (id, dish_id, title, source, source_url, instructions, yield_quantity, yield_unit, complexity_tier, submitted_by_user_id, provenance, validity_window_end_date)
SELECT gen_random_uuid(), d.id, r.title, r.source, NULL, r.instructions, r.yield_qty, r.yield_unit, r.complexity::complexity_tier, NULL, 'llm_inferred_low_confidence'::provenance_type, r.validity_end::date
FROM (VALUES
  ('American cheeseburger (classic diner-style, Houston metro April 2026)', 'Engine B v1.1 decomposition', 'Form 4-6 oz patty loosely from 80/20 ground chuck. Season with salt and pepper IMMEDIATELY before cook. Cook on griddle or cast iron at 400-500F for 3-4 min per side. Place American cheese slice on patty in last 30 sec; cover with cloche for melt. Rest patty 2 min. Toast bun face-down with butter on griddle 30-60 sec. Spread mayo on top bun, ketchup on bottom bun. Assemble bottom-up: bun, condiment, lettuce, patty+cheese, tomato slice, onion rings, pickle chips, top bun. Serve immediately.', 1, 'burger', 'basic_prep', '2026-06-30'),
  ('Beef patty (formed, classic diner)', 'Engine B v1.1 decomposition', 'Loosely form 80/20 ground chuck (or chuck-brisket blend for premium) into 4-6 oz puck. Handle minimally; over-packed patty becomes dense. Season with kosher salt and fresh ground black pepper IMMEDIATELY before cook. Cook on griddle or cast iron at 400-500F, 3-4 min per side for medium. Do NOT press patty during cook. Place cheese in last 30 sec, cover with cloche. Rest 2 min before assembly.', 1, 'patty', 'basic_prep', NULL),
  ('Burger bun preparation (toasted)', 'Engine B v1.1 decomposition', 'Split bun in half. Apply softened butter to cut faces. Toast face-down on griddle at 350-400F for 30-60 sec until golden brown. Critical: untoasted bun absorbs juice and falls apart. This is the detail separating diner-quality from amateur burger.', 1, 'bun', 'basic_prep', NULL),
  ('Vegetable garnish (lettuce, tomato, onion, pickle)', 'Engine B v1.1 decomposition', 'Wash and dry 1-2 lettuce leaves. Slice tomato into thick 1/4-inch rounds. Slice onion into thin rings. Drain dill pickle chips. Assemble at service.', 1, 'serving', 'basic_prep', NULL),
  ('Condiment application (mayo, ketchup, mustard)', 'Engine B v1.1 decomposition', 'Apply mayonnaise to top bun face after toasting. Apply ketchup to bottom bun face or top of patty. Apply yellow mustard if desired (optional).', 1, 'serving', 'basic_prep', NULL)
) AS r(title, source, instructions, yield_qty, yield_unit, complexity, validity_end)
LEFT JOIN dishes d ON d.name = 'American cheeseburger (classic diner-style)' AND r.title LIKE 'American cheeseburger%';

-- ============================================================
-- RECIPE_INGREDIENTS
-- ============================================================

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('american_cheese_single_slice', 20::numeric, 'g', 'single slice'::text, 'secondary_protein', false, 'Sodium citrate in American cheese produces smooth melt without breaking; food-science reason, not just nostalgia.'::text)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'American cheeseburger (classic diner-style, Houston metro April 2026)';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('ground_beef_80_20_chuck', 142::numeric, 'g', 'loosely formed into puck, NOT packed'::text, 'primary_protein', 'Default 80/20 chuck. Premium upgrade: chuck-brisket blend.'::text),
  ('fine_sea_salt', 1.5, 'g', 'applied immediately before cook', 'salt_seasoning', 'Salt timing matters: pre-salting hours in advance creates dense rubbery patty.'),
  ('black_pepper_fresh_ground', 0.5, 'g', 'applied immediately before cook', 'spice_base', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Beef patty (formed, classic diner)';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('bun_soft_white_sesame_top_classic', 70::numeric, 'g', 'split, butter cut faces, toast face-down'::text, 'starch_base', NULL::text),
  ('butter_unsalted_softened', 5, 'g', 'softened, applied to cut faces', 'flavor_fat', 'For toasting bun faces.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Burger bun preparation (toasted)';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('lettuce_iceberg', 15::numeric, 'g', '1-2 leaves, washed and dried'::text, 'vegetable_substance', false, 'Iceberg = classic diner crunch. Acts as moisture barrier between patty and bottom bun.'::text),
  ('tomato_beefsteak_slicing', 30, 'g', 'thick 1/4-inch round slice', 'vegetable_substance', false, 'Tomato quality varies seasonally; April Houston decent, May-September peak.'),
  ('onion_white_or_yellow_raw_thin_sliced', 15, 'g', 'thin rings, 1-2 rings', 'aromatic_finishing', false, 'White or yellow onion classic; red is sharper.'),
  ('pickles_dill_chips_kosher', 10, 'g', '3-4 chips, drained', 'pickle_component', false, 'Dill chips diner-canonical.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Vegetable garnish (lettuce, tomato, onion, pickle)';

INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('mayonnaise', 8::numeric, 'g', 'applied to top bun face after toasting'::text, 'condiment_component', false, NULL::text),
  ('ketchup_heinz_or_hunts', 8, 'g', 'applied to bottom bun face or top of patty', 'condiment_component', false, NULL),
  ('yellow_mustard_frenchs', 4, 'g', 'optional', 'condiment_component', true, 'Optional; some prefer mayo+ketchup only.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Condiment application (mayo, ketchup, mustard)';

-- ============================================================
-- RECIPE_SUB_RECIPES
-- ============================================================

INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, link.qty, link.unit, link.step_order, false, link.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('American cheeseburger (classic diner-style, Houston metro April 2026)', 'Beef patty (formed, classic diner)', 'primary_protein', 142::numeric, 'g', 3, '4-6 oz patty.'::text),
  ('American cheeseburger (classic diner-style, Houston metro April 2026)', 'Burger bun preparation (toasted)', 'starch_base', 70, 'g', 1, 'Toasted before assembly.'),
  ('American cheeseburger (classic diner-style, Houston metro April 2026)', 'Vegetable garnish (lettuce, tomato, onion, pickle)', 'vegetable_substance', 70, 'g', 5, 'Lettuce, tomato, onion, pickle assembled at service.'),
  ('American cheeseburger (classic diner-style, Houston metro April 2026)', 'Condiment application (mayo, ketchup, mustard)', 'condiment_component', 20, 'g', 2, 'Mayo on top bun, ketchup on bottom, mustard optional.')
) AS link(parent_title, child_title, role_name, qty, unit, step_order, notes)
JOIN recipes parent ON parent.title = link.parent_title
JOIN recipes child ON child.title = link.child_title
JOIN ingredient_roles role ON role.name = link.role_name;

-- ============================================================
-- RECIPE_TECHNIQUES
-- ============================================================

INSERT INTO recipe_techniques (id, recipe_id, technique_id, step_order, notes, provenance)
SELECT gen_random_uuid(), r.id, t.id, rt.step_order, rt.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('American cheeseburger (classic diner-style, Houston metro April 2026)', 'assembly_layered_burger', 1, NULL::text),
  ('American cheeseburger (classic diner-style, Houston metro April 2026)', 'assemble_in_order_bottom_to_top', 2, 'Lettuce-on-bottom prevents tomato juice soaking bun.'),
  ('Beef patty (formed, classic diner)', 'form_patty_loose_no_packing', 1, NULL),
  ('Beef patty (formed, classic diner)', 'season_immediately_before_cook', 2, 'Salt timing critical.'),
  ('Beef patty (formed, classic diner)', 'cook_high_heat_dry_or_griddle_3_to_4min_per_side_for_medium', 3, NULL),
  ('Beef patty (formed, classic diner)', 'place_cheese_on_patty_30sec_before_pull_from_heat', 4, 'Cover with cloche for melt acceleration.'),
  ('Beef patty (formed, classic diner)', 'rest_briefly_before_assembly_2min', 5, NULL),
  ('Burger bun preparation (toasted)', 'toast_bun_buttered_face_down_on_griddle_30_to_60sec', 1, 'THE detail separating diner-quality from amateur burger.'),
  ('Vegetable garnish (lettuce, tomato, onion, pickle)', 'slice_tomato_thick_round', 1, NULL),
  ('Vegetable garnish (lettuce, tomato, onion, pickle)', 'slice_onion_thin_rings', 2, NULL),
  ('Condiment application (mayo, ketchup, mustard)', 'spread_condiment_on_bun_face', 1, NULL)
) AS rt(recipe_title, technique_name, step_order, notes)
JOIN recipes r ON r.title = rt.recipe_title
JOIN techniques t ON t.name = rt.technique_name;

-- ============================================================
-- SUBSTITUTIONS (11 rows)
-- ============================================================

INSERT INTO substitutions (id, original_ingredient_id, substitute_ingredient_id, role_id, cuisine_id, substitution_purpose, substitution_kind, alternative_technique_id, quality_match_score, cost_direction, technique_adjustment_notes, notes, verified_by_user_id, provenance, regional_weight, seasonal_weight)
SELECT gen_random_uuid(),
       orig.id, sub.id, role.id, cuis.id,
       s.purpose::substitution_purpose, s.kind::substitution_kind,
       alt_tech.id,
       s.quality_score, s.cost_dir::cost_direction,
       s.technique_notes, s.tradeoff_notes,
       NULL::uuid,
       'llm_inferred_low_confidence'::provenance_type,
       s.regional::regional_weight_tier,
       s.seasonal::seasonal_weight_tier
FROM (VALUES
  ('ground_beef_80_20_chuck', 'ground_beef_chuck_brisket_blend_60_40', 'primary_protein', 'American',
   'quality_improvement', 'ingredient_swap', 0.95::numeric, 'more_expensive', NULL::text, NULL,
   'Lose: cost-effectiveness for high-volume operations. Gain: deeper beef flavor (brisket adds rich beefy umami), better fat distribution, premium positioning. Compensate: pricing must adjust ~$1-2 per burger. When appropriate: premium burger menu, gastropub positioning, weekend specials. When NOT appropriate: classic American diner positioning at $8 burger price point.',
   'high', 'stable'),
  ('ground_beef_80_20_chuck', 'ground_beef_90_10_lean', 'primary_protein', 'American',
   'dietary_restriction', 'ingredient_swap', 0.50, 'similar', NULL,
   'Reduce cook time aggressively, do NOT press patty during cook, add 1 tbsp butter to top of patty in last 30 seconds.',
   'Lose: juiciness, flavor, texture; lean burgers are dry and hockey-puck. Gain: marginal calorie reduction, perceived "healthier". When appropriate: customer-requested only; never as default. When NOT appropriate: classic diner burger menu position; this is a different product.',
   'high', 'stable'),
  ('ground_beef_pre_ground_supermarket_unspecified', 'ground_beef_80_20_chuck', 'primary_protein', 'American',
   'quality_improvement', 'ingredient_swap', 0.85, 'more_expensive', NULL, NULL,
   'Lose: convenience of grocery aisle pickup. Gain: known cut, fresh grind (better flavor and texture), control over fat ratio. Compensate: requires butcher relationship and 24-hour turnaround for custom grind. When appropriate: any operation positioning on burger quality. When NOT appropriate: high-volume operations buying frozen patties.',
   'high', 'stable'),
  ('ground_beef_80_20_chuck', 'ground_turkey', 'primary_protein', 'American',
   'dietary_restriction', 'ingredient_swap', 0.40, 'cheaper', NULL,
   'Add 1 tsp Worcestershire sauce to ground turkey, cook to 165F internal (food safety), serve with extra moisture (avocado, mayo, melted cheese).',
   'Lose: beef flavor entirely; this is now a turkey burger, different product. Gain: lower fat (perceived healthier), poultry option. When appropriate: explicit turkey burger menu position. When NOT appropriate: claiming "cheeseburger" without qualifier.',
   'high', 'stable'),
  ('ground_beef_80_20_chuck', 'plant_based_patty_beyond_or_impossible', 'primary_protein', 'American',
   'dietary_restriction', 'ingredient_swap', 0.55, 'more_expensive', NULL,
   'Cook to package directions (do NOT overcook; plant patties dry out fast); use same toppings as beef burger; rebrand as "plant-based burger" not "beef cheeseburger".',
   'Lose: real beef flavor (close but distinguishable), traditional dish identity. Gain: vegetarian/vegan option, broader market reach. When appropriate: vegetarian/vegan menu position, broader market. When NOT appropriate: pretending it''s a beef burger.',
   'high', 'stable'),
  ('american_cheese_single_slice', 'cheddar_aged', 'secondary_protein', 'American',
   'quality_improvement', 'ingredient_swap', 0.65, 'more_expensive', NULL,
   'Shred cheddar finely so partial melt is acceptable; or accept the broken-melt aesthetic as "rustic".',
   'Lose: smooth even melt; aged cheddar breaks into oil-and-curd when melted on hot patty (real food science: lacks sodium citrate emulsifiers). Gain: pronounced cheese flavor, "premium" perception, gastropub positioning. When appropriate: gastropub menu, customers who specifically want sharp cheese flavor. When NOT appropriate: classic diner aesthetic where smooth melt is part of the visual.',
   'high', 'stable'),
  ('american_cheese_single_slice', 'pepper_jack', 'secondary_protein', 'American',
   'cuisine_translation', 'ingredient_swap', 0.75, 'similar', NULL, NULL,
   'Lose: classic diner aesthetic. Gain: Texas/Southwest regional appeal, mild heat. Compensate: minimal; pepper jack melts reasonably. When appropriate: Texas-themed menu, Tex-Mex burger fusion. When NOT appropriate: classic Northeast diner positioning.',
   'high', 'stable'),
  ('bun_soft_white_sesame_top_classic', 'bun_brioche', 'starch_base', 'American',
   'quality_improvement', 'ingredient_swap', 0.80, 'more_expensive', NULL,
   'Toast brioche aggressively to firm structure; serve immediately.',
   'Lose: classic diner aesthetic, structural integrity (brioche dissolves faster in juice). Gain: butter-rich flavor, premium positioning. When appropriate: gastropub or upscale positioning. When NOT appropriate: classic American diner identity.',
   'high', 'stable'),
  ('bun_soft_white_sesame_top_classic', 'bun_pretzel', 'starch_base', 'American',
   'cuisine_translation', 'ingredient_swap', 0.65, 'more_expensive', NULL,
   'Dense bun is hard to bite; consider thinner patty.',
   'Lose: traditional softness. Gain: distinctive texture, savory flavor, brewpub aesthetic. When appropriate: brewpub-themed menu. When NOT appropriate: classic diner.',
   'medium', 'stable'),
  ('lettuce_iceberg', 'lettuce_butter_bibb', 'vegetable_substance', 'American',
   'quality_improvement', 'ingredient_swap', 0.75, 'more_expensive', NULL, NULL,
   'Lose: iceberg distinctive crunch (some customers specifically want this). Gain: softer texture, more delicate flavor, more visually elegant. When appropriate: modern burger positioning. When NOT appropriate: classic diner where iceberg crunch is part of identity.',
   'high', 'stable'),
  ('tomato_beefsteak_slicing', 'tomato_beefsteak_slicing', 'vegetable_substance', 'American',
   'cost_reduction', 'technique_swap', 0.30, 'similar', NULL,
   'For off-season hothouse tomato: omit tomato slice or substitute roasted tomato (concentrated flavor, no wateriness).',
   'Anti-pattern flag for off-season. Lose: classic burger aesthetic with raw tomato slice. Gain: avoiding mealy off-season hothouse tomato that sucks juice and adds nothing. When appropriate: winter/off-season menu in regions where tomato is poor. When NOT appropriate: April-October Houston when tomato is good.',
   'low', 'off_season')
) AS s(orig_canonical, sub_canonical, role_name, cuisine_name, purpose, kind, quality_score, cost_dir, alt_tech_name, technique_notes, tradeoff_notes, regional, seasonal)
JOIN ingredients orig ON orig.canonical_name = s.orig_canonical
JOIN ingredients sub ON sub.canonical_name = s.sub_canonical
JOIN ingredient_roles role ON role.name = s.role_name
JOIN cuisines cuis ON cuis.name = s.cuisine_name
LEFT JOIN techniques alt_tech ON alt_tech.name = s.alt_tech_name;

COMMIT;
