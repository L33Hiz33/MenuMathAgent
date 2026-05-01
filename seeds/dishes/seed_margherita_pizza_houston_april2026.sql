-- ============================================================
-- Seed: Pizza margherita (Neapolitan AVPN-style, Houston metro, April 2026)
-- Third real seed via Engine B output (v1.1 prompt, iteration 3, score 9.1).
--
-- Provenance for ALL rows: llm_inferred_low_confidence
-- All rows await human review and promotion.
--
-- Run after: banh mi + tonkotsu seeds completed.
-- This seed reuses cooking_methods (6) and ingredient_categories (7).
-- Adds Italian cuisine, new equipment, new techniques, new ingredients.
--
-- All inserts in a single transaction.
-- ============================================================

BEGIN;

-- ============================================================
-- EQUIPMENT (8 new rows)
-- ============================================================

INSERT INTO equipment (id, name, equipment_type, thermal_property_notes, max_practical_temp_f, description, provenance) VALUES
  (gen_random_uuid(), 'pizza_oven_wood_fired', 'heat_source', 'Traditional Neapolitan oven; oak or fruit wood; achieves 900F+ floor temp.', 1000, 'Wood-fired pizza oven; AVPN-canonical heat source for Neapolitan pizza.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'pizza_oven_gas_fired_neapolitan', 'heat_source', 'Modern gas-fired Neapolitan-style oven (Roccbox, Ooni, Gozney).', 950, 'Gas-fired Neapolitan oven achieving 850-900F; food truck friendly.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'pizza_steel', 'vessel', 'Heavy steel plate preheated 1+ hour in home oven.', 600, 'Pizza steel for home oven approximation of Neapolitan bake.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'pizza_peel_wood', 'tool', 'Wooden peel for transferring shaped pizza onto oven floor.', NULL, 'Wooden pizza peel for launching uncooked pizza into oven.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'pizza_peel_metal', 'tool', 'Metal peel for retrieving baked pizza.', NULL, 'Metal pizza peel for removing baked pizza from hot oven.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'planetary_mixer', 'appliance', NULL, NULL, 'Stand mixer with planetary action for dough mixing; alternative to hand kneading.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'pizza_dough_proofing_box', 'vessel', 'Ambient or temperature-controlled fermentation chamber for dough balls.', 80, 'Dedicated proofing container for pizza dough panetti.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'food_grater', 'tool', NULL, NULL, 'Microplane or box grater for cheese application.', 'llm_inferred_low_confidence');

-- ============================================================
-- TECHNIQUES (22 new rows)
-- ============================================================

INSERT INTO techniques (id, name, method_id, primary_equipment_id, secondary_equipment_id, temperature_range_f, duration_range, difficulty_tier, notes, provenance)
SELECT gen_random_uuid(), t.name, cm.id, eq1.id, eq2.id, t.temp, t.duration, t.difficulty::technique_difficulty, t.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('assembly_then_high_heat_bake', 'no_heat', 'mixing_bowl', NULL::text, NULL::text, '5-10 min assembly + 60-90 sec bake', 'intermediate', 'Top-level technique for Neapolitan pizza: cold assembly followed by very hot, very fast bake.'),
  ('mix_water_and_yeast_first', 'no_heat', 'mixing_bowl', NULL, NULL, '1-2 min', 'beginner', 'Dissolve yeast in water before adding flour to ensure even distribution.'),
  ('gradual_flour_incorporation_no_kneading_machine', 'no_heat', 'mixing_bowl', NULL, NULL, '5 min', 'beginner', 'Add flour gradually to water-yeast mix to avoid lumps before machine kneading begins.'),
  ('knead_by_hand_or_planetary_mixer_low_speed_15min', 'no_heat', 'planetary_mixer', NULL, NULL, '15 min', 'intermediate', 'Dough is wet and sticky; resist adding flour during knead. Hand kneading also works but takes longer.'),
  ('bulk_ferment_room_temp_2hr', 'fermentation', 'pizza_dough_proofing_box', NULL, '70-78', '2 hours', 'beginner', 'Initial bulk fermentation at room temperature before dividing into balls.'),
  ('divide_into_balls_panetti_220_to_280g_each', 'no_heat', 'mixing_bowl', NULL, NULL, '5 min', 'beginner', 'AVPN spec: panetti weight 220-280g each for ~30cm pizza.'),
  ('final_proof_room_temp_4_to_8hr_or_cold_proof_24hr', 'fermentation', 'pizza_dough_proofing_box', NULL, '70-78', '4-24 hours', 'beginner', 'Either 4-8 hour ambient proof OR 24 hour cold proof in refrigerator. Cold proof develops more flavor.'),
  ('hand_shape_NEVER_rolling_pin_to_preserve_cornicione', 'no_heat', 'mixing_bowl', NULL, NULL, '1-2 min per ball', 'intermediate', 'AVPN explicitly prohibits rolling pin. Push from center outward, leave edge thicker for cornicione (puffy outer crust). Rolling pin destroys air pockets in edge.'),
  ('crush_tomatoes_by_hand_NOT_blender', 'no_heat', 'mixing_bowl', NULL, NULL, '2 min', 'beginner', 'Hand-crush whole peeled tomatoes. Blending introduces seed bitterness and over-purees the sauce.'),
  ('season_lightly_with_salt', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'beginner', 'Light salt only. Sauce cooks in oven during pizza bake; do not over-season raw.'),
  ('hand_tear_into_walnut_sized_pieces', 'no_heat', 'mixing_bowl', NULL, NULL, '1 min', 'beginner', 'Tear fior di latte into irregular pieces. Slicing creates uniform shapes that brown poorly; tearing creates surface irregularity for better Maillard.'),
  ('drain_excess_moisture_pre_bake', 'no_heat', 'mixing_bowl', NULL, NULL, '1 hour', 'beginner', 'For wet fresh fior di latte: tear, place on paper towels, drain 1 hour before topping pizza. Reduces sogginess in bake.'),
  ('spread_sauce_thin_circular', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'beginner', 'Spoon raw crushed tomato in center, spread in spiral pattern outward. Leave 1-2 cm cornicione edge sauce-free.'),
  ('arrange_cheese_irregular_pattern', 'no_heat', 'mixing_bowl', NULL, NULL, '1 min', 'beginner', 'Place torn cheese pieces irregularly across sauce. AVPN does not specify uniform coverage; gaps are acceptable and traditional.'),
  ('place_basil_pre_bake', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'beginner', 'Some basil leaves placed before bake (often under cheese for protected aroma). Will partially shrink and crisp.'),
  ('drizzle_olive_oil_spiral_pattern', 'no_heat', 'mixing_bowl', NULL, NULL, '15 sec', 'beginner', 'Extra virgin olive oil drizzled in spiral pattern over assembled pizza before bake.'),
  ('transfer_to_peel_then_oven', 'no_heat', 'pizza_peel_wood', NULL, NULL, '30 sec', 'intermediate', 'Launch is the hardest part for novice pizzaiolos. Lightly flour peel; assemble pizza directly on peel; quick confident slide onto oven floor.'),
  ('bake_60_to_90_seconds_at_900F', 'dry_heat', 'pizza_oven_wood_fired', 'pizza_peel_wood', '850-950', '60-90 sec', 'advanced', 'AVPN spec. Rotate pizza 90 degrees halfway through bake. Cornicione should leopard (dark spots) but not burn.'),
  ('bake_60_to_90_seconds_at_900F_gas_fired', 'dry_heat', 'pizza_oven_gas_fired_neapolitan', 'pizza_peel_wood', '850-950', '60-90 sec', 'advanced', 'Same as wood-fired but gas. Slightly less smoke flavor; still AVPN-compliant for Neapolitan style.'),
  ('bake_home_oven_with_steel_8_to_12_min_at_550F', 'dry_heat', 'pizza_steel', NULL, '550', '8-12 min', 'intermediate', 'Substitute for proper Neapolitan bake. Preheat steel 1+ hour at max oven temp. Broil-blast last 1-2 min for top char. NOT AVPN-spec.'),
  ('retrieve_with_metal_peel', 'no_heat', 'pizza_peel_metal', NULL, NULL, '15 sec', 'beginner', 'Use metal peel (slimmer than wooden) to retrieve baked pizza from oven floor.'),
  ('apply_fresh_basil_post_bake', 'no_heat', 'mixing_bowl', NULL, NULL, '15 sec', 'beginner', 'Additional fresh basil leaves applied AFTER bake to preserve volatile aromatic compounds destroyed by 900F heat.'),
  ('finishing_oil_drizzle_post_bake', 'no_heat', 'mixing_bowl', NULL, NULL, '15 sec', 'beginner', 'Optional second drizzle of extra virgin olive oil after bake. AVPN allows but does not mandate.')
) AS t(name, method_name, primary_eq_name, secondary_eq_name, temp, duration, difficulty, notes)
JOIN cooking_methods cm ON cm.name = t.method_name
JOIN equipment eq1 ON eq1.name = t.primary_eq_name
LEFT JOIN equipment eq2 ON eq2.name = t.secondary_eq_name;

-- ============================================================
-- CUISINE (1 new row)
-- ============================================================

INSERT INTO cuisines (id, name, parent_id, region_bias, description, provenance) VALUES
  (gen_random_uuid(), 'Italian', NULL, 'Mediterranean Europe', 'Italian cuisine, encompassing strong regional variants (Campanian, Tuscan, Sicilian, Lombard, etc.).', 'llm_inferred_low_confidence');

-- ============================================================
-- INGREDIENTS (~25 new rows)
-- ============================================================

INSERT INTO ingredients (id, canonical_name, display_name, category_id, subcategory_id, default_unit, usda_commodity_code, description, provenance)
SELECT gen_random_uuid(), i.canonical_name, i.display_name, cat.id, NULL, i.default_unit, NULL, i.description, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  -- Pantry (flours, salts already exist; new specifics)
  ('flour_00_caputo_pizzeria_or_equivalent', 'Flour, 00 (Caputo Pizzeria or equivalent)', 'pantry', 'g', 'Italian tipo 00 fine-milled low-protein flour. AVPN spec W index 220-280. Critical for Neapolitan pizza dough texture.'),
  ('flour_bread_american_high_protein', 'Flour, bread (American high-protein)', 'pantry', 'g', 'American bread flour as substitute for 00; higher protein content yields chewier crust, less Neapolitan.'),
  ('water_filtered_room_temp', 'Water, filtered, room temperature', 'pantry', 'ml', 'Filtered water at room temperature for pizza dough hydration.'),
  ('yeast_fresh_lievito_di_birra', 'Yeast, fresh (lievito di birra)', 'pantry', 'g', 'Fresh compressed yeast traditional in Italian bakeries; minimal aroma advantage at low-yeast pizza dough hydration.'),
  ('yeast_instant_dry', 'Yeast, instant dry', 'pantry', 'g', 'Commercial instant dry yeast; substitute for fresh at 1/3 the weight.'),
  -- Tomatoes
  ('san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 'San Marzano DOP whole peeled tomatoes (Pomodoro dell''Agro Sarnese-Nocerino)', 'vegetables', 'g', 'DOP-certified plum tomatoes grown in volcanic soil of Mt. Vesuvius region. Sweeter and lower-acid than standard plum tomato. AVPN-canonical.'),
  ('plum_tomatoes_whole_peeled_standard', 'Plum tomatoes, whole peeled, standard', 'vegetables', 'g', 'Standard canned whole peeled plum tomatoes; cost-down substitute for San Marzano DOP.'),
  ('san_marzano_style_us_grown_bianco_dinapoli_or_cento', 'San Marzano-style, US-grown (Bianco DiNapoli or Cento)', 'vegetables', 'g', 'US-grown San Marzano variety tomatoes; closer flavor profile than no-name plum tomatoes; not DOP-certified.'),
  -- Cheese
  ('fior_di_latte_fresh_cow_milk_mozzarella', 'Fior di latte (fresh cow milk mozzarella)', 'dairy', 'g', 'Fresh cow milk mozzarella; AVPN-permitted for standard Margherita. Pre-drained pizza-specific version preferred.'),
  ('mozzarella_di_bufala_dop_buffalo_milk', 'Mozzarella di bufala DOP (buffalo milk)', 'dairy', 'g', 'Buffalo milk mozzarella with DOP certification; higher fat, more pronounced milky tang. AVPN Margherita STG version. ~3x cost of cow milk.'),
  ('low_moisture_mozzarella_american_pizza_cheese', 'Low-moisture mozzarella (American pizza cheese)', 'dairy', 'g', 'American-style aged low-moisture mozzarella; denser, drier, saltier than fresh; standard for Italian-American pizza, not Neapolitan.'),
  -- Herbs and oil
  ('basil_fresh_genovese', 'Basil, fresh, Genovese', 'vegetables', 'g', 'Genovese basil cultivar; canonical Italian variety with anise-clove character. AVPN-canonical for margherita.'),
  ('basil_fresh_mixed_varieties', 'Basil, fresh, mixed varieties (Thai, lemon, sweet)', 'vegetables', 'g', 'Non-Genovese basil varieties; substitute when Genovese unavailable; flavor profile differs significantly.'),
  ('olive_oil_extra_virgin_italian_tuscan_or_sicilian', 'Olive oil, extra virgin, Italian (Tuscan or Sicilian)', 'fats_and_oils', 'ml', 'Italian extra virgin olive oil, peppery and fruity; finishing and dough oil for Neapolitan margherita.'),
  -- Optional service additions
  ('sea_salt_finishing_flake_maldon_or_fleur_de_sel', 'Sea salt, finishing flake (Maldon or fleur de sel)', 'pantry', 'g', 'Flake finishing salt; optional service addition; AVPN does not mandate.'),
  ('pecorino_romano_grated', 'Pecorino Romano, grated', 'dairy', 'g', 'Aged sheep''s milk cheese, grated; NOT canonical AVPN margherita; some Italian-American traditions add.'),
  ('parmigiano_reggiano_grated', 'Parmigiano-Reggiano, grated', 'dairy', 'g', 'DOP-certified aged cow''s milk cheese, grated; NOT canonical AVPN margherita; Italian-American addition.')
) AS i(canonical_name, display_name, category_name, default_unit, description)
JOIN ingredient_categories cat ON cat.name = i.category_name;

-- ============================================================
-- INGREDIENT ALIASES (Italian to English)
-- ============================================================

INSERT INTO ingredient_aliases (id, ingredient_id, alias_name, language, region_origin, notes, provenance)
SELECT gen_random_uuid(), ing.id, a.alias_name, a.language, a.region_origin, a.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('flour_00_caputo_pizzeria_or_equivalent', 'tipo 00 flour', 'it', 'Italy', 'Italian classification for finest-milled flour.'),
  ('flour_00_caputo_pizzeria_or_equivalent', 'doppio zero flour', 'it', 'Italy', 'Literal Italian: "double zero" flour.'),
  ('yeast_fresh_lievito_di_birra', 'lievito di birra', 'it', 'Italy', 'Italian name; literally "beer yeast" though used for bread.'),
  ('yeast_fresh_lievito_di_birra', 'fresh compressed yeast', 'en', 'global', 'English description of cake yeast format.'),
  ('san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 'pomodoro San Marzano DOP', 'it', 'Italy', 'Italian DOP-certified name.'),
  ('san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 'San Marzano DOP', 'en', 'common usage', 'Common English shortened form.'),
  ('fior_di_latte_fresh_cow_milk_mozzarella', 'fior di latte', 'it', 'Italy', 'Italian: "flower of milk"; cow-milk fresh mozzarella for pizza.'),
  ('fior_di_latte_fresh_cow_milk_mozzarella', 'fresh cow milk mozzarella', 'en', 'global', 'English description.'),
  ('mozzarella_di_bufala_dop_buffalo_milk', 'mozzarella di bufala campana DOP', 'it', 'Italy', 'Full DOP-certified Italian designation.'),
  ('mozzarella_di_bufala_dop_buffalo_milk', 'buffalo mozzarella', 'en', 'global', 'Common English shortened form.'),
  ('basil_fresh_genovese', 'basilico genovese', 'it', 'Italy', 'Italian name for the canonical pizza basil cultivar.'),
  ('basil_fresh_genovese', 'sweet basil', 'en', 'common usage', 'Common English term often used (loosely) for Genovese.'),
  ('olive_oil_extra_virgin_italian_tuscan_or_sicilian', 'olio extravergine d''oliva', 'it', 'Italy', 'Italian designation for EVOO.'),
  ('olive_oil_extra_virgin_italian_tuscan_or_sicilian', 'EVOO', 'en', 'common usage', 'Common abbreviation in American kitchens.'),
  ('parmigiano_reggiano_grated', 'parmesan', 'en', 'common usage', 'Common American name; technically not the same protected DOP cheese but used interchangeably.')
) AS a(canonical_name, alias_name, language, region_origin, notes)
JOIN ingredients ing ON ing.canonical_name = a.canonical_name;

-- ============================================================
-- DISH (1 new row)
-- ============================================================

INSERT INTO dishes (id, name, cuisine_id, archetype_id, description, complexity_tier, provenance)
SELECT gen_random_uuid(), 'Pizza margherita (Neapolitan AVPN-style)', c.id, NULL,
  'Neapolitan pizza margherita conforming to AVPN (Associazione Verace Pizza Napoletana) specifications. Dough of tipo 00 flour at 60-65% hydration with 24-hour fermentation, hand-shaped (no rolling pin). Topped with raw crushed San Marzano DOP tomatoes, torn fior di latte (cow milk mozzarella; buffalo milk version is Margherita STG), Genovese basil, and extra virgin olive oil. Baked 60-90 seconds at 850-950F in wood-fired or gas-fired Neapolitan oven. The "Margherita" name honors Queen Margherita of Savoy (1889 Naples).',
  'intermediate'::complexity_tier, 'llm_inferred_low_confidence'::provenance_type
FROM cuisines c WHERE c.name = 'Italian';

-- ============================================================
-- RECIPES (5 rows: 1 parent + 4 sub-recipes)
-- ============================================================

INSERT INTO recipes (id, dish_id, title, source, source_url, instructions, yield_quantity, yield_unit, complexity_tier, submitted_by_user_id, provenance, validity_window_end_date)
SELECT gen_random_uuid(), d.id, r.title, r.source, NULL, r.instructions, r.yield_qty, r.yield_unit, r.complexity::complexity_tier, NULL, 'llm_inferred_low_confidence'::provenance_type, r.validity_end::date
FROM (VALUES
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'Engine B v1.1 decomposition', 'Hand-shape proofed dough ball into 30 cm round on lightly floured peel, leaving 1-2 cm thick cornicione edge. Spread 80-100g raw crushed San Marzano sauce in spiral pattern, leaving cornicione bare. Tear 80g fior di latte into walnut-sized pieces, arrange irregularly across sauce. Place 3-4 basil leaves on top. Drizzle 5 ml extra virgin olive oil in spiral. Slide onto 900F oven floor. Bake 60-90 seconds, rotating 90 degrees halfway through. Retrieve with metal peel. Apply 2-3 fresh basil leaves post-bake. Optional second oil drizzle. Serve immediately.', 1, 'pizza', 'intermediate', '2026-06-30'),
  ('Neapolitan pizza dough', 'Engine B v1.1 decomposition', 'Dissolve yeast in filtered room-temp water. Gradually incorporate 00 flour. Add salt after partial mixing. Knead 15 minutes by hand or planetary mixer at low speed; resist adding flour during knead. Bulk ferment 2 hours at 70-78F. Divide into 220-280g balls. Final proof 4-8 hours room temp OR 24 hours cold proof. Hand-shape each ball into 30 cm round; NEVER use rolling pin (destroys cornicione air pockets).', 4, 'panetti (~250g each)', 'intermediate', NULL),
  ('San Marzano tomato sauce (raw crushed)', 'Engine B v1.1 decomposition', 'Open can of San Marzano DOP whole peeled tomatoes. Drain excess liquid (reserve for thinner sauce or stocks). Crush tomatoes by hand into a chunky pulp; do NOT blender (over-purees and introduces seed bitterness). Season with light salt. Optional: add small drizzle of olive oil. DO NOT COOK. The 60-90 second pizza bake at 900F cooks the raw tomato perfectly. Pre-cooking is a common American error.', 350, 'g', 'basic_prep', NULL),
  ('Fior di latte preparation', 'Engine B v1.1 decomposition', 'Hand-tear fior di latte into walnut-sized irregular pieces. If using fresh wet fior di latte (not pre-drained pizza-specific), place torn pieces on paper towels and drain 1 hour before topping pizza. This reduces wateriness during the bake.', 80, 'g', 'basic_prep', NULL),
  ('Basil and finishing oil application', 'Engine B v1.1 decomposition', 'Reserve 4-6 fresh Genovese basil leaves per pizza. Apply 3-4 leaves before bake (some under cheese for protected aroma). Apply 2-3 leaves AFTER bake to preserve volatile aromatic compounds destroyed by 900F heat. Drizzle 5-10 ml extra virgin olive oil in spiral pattern before bake; optional second drizzle after.', 1, 'pizza_application', 'basic_prep', NULL)
) AS r(title, source, instructions, yield_qty, yield_unit, complexity, validity_end)
LEFT JOIN dishes d ON d.name = 'Pizza margherita (Neapolitan AVPN-style)' AND r.title LIKE 'Pizza margherita%';

-- ============================================================
-- RECIPE_INGREDIENTS
-- ============================================================

-- Parent margherita recipe direct ingredients (all consolidated into sub-recipes; only optional service items here)
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('sea_salt_finishing_flake_maldon_or_fleur_de_sel', 0.3::numeric, 'g', 'pinch'::text, 'salt_finishing', true, 'Optional service addition; AVPN does not mandate.'::text)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)';

-- Neapolitan pizza dough sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('flour_00_caputo_pizzeria_or_equivalent', 1000::numeric, 'g', NULL::text, 'dough_structure', 'AVPN spec W index 220-280.'::text),
  ('water_filtered_room_temp', 625, 'ml', 'room temperature', 'cooking_liquid', 'Hydration 60-65%; lower than artisan bread to allow shaping.'),
  ('fine_sea_salt', 27, 'g', NULL, 'salt_seasoning', 'AVPN spec 40-60 g/L water. Add after partial mixing to avoid killing yeast.'),
  ('yeast_instant_dry', 1, 'g', NULL, 'leavener', 'Minimal yeast for long fermentation. Fresh yeast lievito di birra at 3g is canonical alternative.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Neapolitan pizza dough';

-- San Marzano tomato sauce sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 400::numeric, 'g', 'one can; hand-crushed; do NOT blender'::text, 'vegetable_substance', false, 'AVPN-canonical; check label for DOP seal.'::text),
  ('fine_sea_salt', 2, 'g', NULL, 'salt_seasoning', false, 'Light seasoning; sauce cooks during pizza bake.'),
  ('olive_oil_extra_virgin_italian_tuscan_or_sicilian', 5, 'ml', 'optional drizzle in sauce', 'structural_fat', true, 'Optional; some pizzaiolos add to sauce.'),
  ('basil_fresh_genovese', 2, 'g', '2-3 leaves added to sauce while sitting (optional)', 'aromatic_finishing', true, 'Optional; default = save all basil for finish on pizza.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'San Marzano tomato sauce (raw crushed)';

-- Fior di latte preparation sub-recipe (single ingredient)
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, 80, 'g', 'hand-torn into walnut-sized pieces; drained if wet', role.id, false,
       'Default = pre-drained pizza-specific fior di latte; if only fresh wet available, drain on paper towels 1 hour.',
       'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM recipes r
JOIN ingredients ing ON ing.canonical_name = 'fior_di_latte_fresh_cow_milk_mozzarella'
JOIN ingredient_roles role ON role.name = 'secondary_protein'
WHERE r.title = 'Fior di latte preparation';

-- Basil and finishing oil application sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('basil_fresh_genovese', 6::numeric, 'g', '4-6 leaves: 3-4 pre-bake, 2-3 post-bake'::text, 'aromatic_finishing', false, 'Genovese cultivar canonical; post-bake leaves preserve volatile aromatics destroyed by 900F heat.'::text),
  ('olive_oil_extra_virgin_italian_tuscan_or_sicilian', 7, 'ml', 'spiral drizzle pre-bake; optional second drizzle post-bake', 'flavor_fat', false, 'AVPN allows but does not mandate post-bake drizzle.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Basil and finishing oil application';

-- ============================================================
-- RECIPE_SUB_RECIPES
-- ============================================================

INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, link.qty, link.unit, link.step_order, false, link.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'Neapolitan pizza dough', 'dough_structure', 250::numeric, 'g', 1, 'One panetto (220-280g) hand-shaped to 30 cm round.'::text),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'San Marzano tomato sauce (raw crushed)', 'sauce_body', 90, 'g', 2, 'Spread in spiral, leave 1-2 cm cornicione edge bare.'),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'Fior di latte preparation', 'secondary_protein', 80, 'g', 3, 'Tear into walnut-sized pieces, arrange irregularly.'),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'Basil and finishing oil application', 'aromatic_finishing', 1, 'application', 4, 'Pre-bake and post-bake basil + oil treatment.')
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
  -- Parent pizza margherita
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'spread_sauce_thin_circular', 1, NULL::text),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'arrange_cheese_irregular_pattern', 2, NULL),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'place_basil_pre_bake', 3, NULL),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'drizzle_olive_oil_spiral_pattern', 4, NULL),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'transfer_to_peel_then_oven', 5, NULL),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'bake_60_to_90_seconds_at_900F', 6, 'Default; gas-fired Neapolitan oven also acceptable for AVPN compliance.'),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'retrieve_with_metal_peel', 7, NULL),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'apply_fresh_basil_post_bake', 8, NULL),
  ('Pizza margherita (Neapolitan AVPN-style, Houston metro April 2026)', 'finishing_oil_drizzle_post_bake', 9, 'Optional.'),
  -- Neapolitan pizza dough
  ('Neapolitan pizza dough', 'mix_water_and_yeast_first', 1, NULL),
  ('Neapolitan pizza dough', 'gradual_flour_incorporation_no_kneading_machine', 2, NULL),
  ('Neapolitan pizza dough', 'knead_by_hand_or_planetary_mixer_low_speed_15min', 3, NULL),
  ('Neapolitan pizza dough', 'bulk_ferment_room_temp_2hr', 4, NULL),
  ('Neapolitan pizza dough', 'divide_into_balls_panetti_220_to_280g_each', 5, NULL),
  ('Neapolitan pizza dough', 'final_proof_room_temp_4_to_8hr_or_cold_proof_24hr', 6, NULL),
  ('Neapolitan pizza dough', 'hand_shape_NEVER_rolling_pin_to_preserve_cornicione', 7, 'AVPN explicit no-rolling-pin rule.'),
  -- San Marzano tomato sauce
  ('San Marzano tomato sauce (raw crushed)', 'crush_tomatoes_by_hand_NOT_blender', 1, NULL),
  ('San Marzano tomato sauce (raw crushed)', 'season_lightly_with_salt', 2, NULL),
  -- Fior di latte preparation
  ('Fior di latte preparation', 'hand_tear_into_walnut_sized_pieces', 1, NULL),
  ('Fior di latte preparation', 'drain_excess_moisture_pre_bake', 2, 'For wet fresh fior di latte only; pre-drained pizza-specific version skips this step.'),
  -- Basil and finishing oil application
  ('Basil and finishing oil application', 'place_basil_pre_bake', 1, NULL),
  ('Basil and finishing oil application', 'drizzle_olive_oil_spiral_pattern', 2, NULL),
  ('Basil and finishing oil application', 'apply_fresh_basil_post_bake', 3, NULL),
  ('Basil and finishing oil application', 'finishing_oil_drizzle_post_bake', 4, 'Optional second drizzle.')
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
  ('flour_00_caputo_pizzeria_or_equivalent', 'flour_bread_american_high_protein', 'dough_structure', 'Italian',
   'availability_swap', 'ingredient_swap', 0.55::numeric, 'cheaper', NULL::text,
   'Reduce hydration to 58-60%, knead less, increase fermentation time slightly.',
   'Lose: 00 flour fine grind and lower W index produce a softer, more extensible dough; cornicione puffs differently. Gain: lower cost, universal availability. When appropriate: when 00 flour is genuinely unavailable. When NOT appropriate: claiming AVPN authenticity; this is no longer Neapolitan-spec dough.',
   'low', 'stable'),
  ('yeast_fresh_lievito_di_birra', 'yeast_instant_dry', 'leavener', 'Italian',
   'availability_swap', 'ingredient_swap', 0.85, 'cheaper', NULL,
   'Use 1/3 the weight of fresh yeast (3g fresh = 1g instant).',
   'Lose: marginal fresh-yeast aroma (small effect at this dough hydration). Gain: shelf life, consistency, easier sourcing. When appropriate: most operations. When NOT appropriate: high-end pizzeria positioning where fresh yeast is part of the food story.',
   'medium', 'stable'),
  ('fior_di_latte_fresh_cow_milk_mozzarella', 'mozzarella_di_bufala_dop_buffalo_milk', 'secondary_protein', 'Italian',
   'quality_improvement', 'ingredient_swap', 0.95, 'more_expensive', NULL,
   'Pricing must adjust ~$2-4 per pizza; buffalo mozzarella is wetter so drain longer.',
   'Lose: cost-effectiveness for high-volume operations. Gain: this is the AVPN Margherita STG version; higher fat, more pronounced milky tang, premium positioning. When appropriate: premium menu positioning, DOC/DOP/STG-focused operations, weekend specials. When NOT appropriate: cost-conscious daily menu.',
   'medium', 'stable'),
  ('fior_di_latte_fresh_cow_milk_mozzarella', 'low_moisture_mozzarella_american_pizza_cheese', 'secondary_protein', 'Italian',
   'cost_reduction', 'ingredient_swap', 0.40, 'cheaper', NULL,
   'Reduce cheese volume by 20%; American low-moisture is denser and saltier.',
   'Lose: fresh mozzarella tearing texture, pronounced milk flavor, soft melt that puddles into sauce. Gain: lower cost, longer shelf life, drier (less wet bake), familiar to American customers. When appropriate: cost-driven Italian-American pizza menu. When NOT appropriate: any margherita claim. This is a different pizza style (Italian-American, not Neapolitan).',
   'high', 'stable'),
  ('san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 'plum_tomatoes_whole_peeled_standard', 'vegetable_substance', 'Italian',
   'cost_reduction', 'ingredient_swap', 0.50, 'cheaper', NULL,
   'Add tiny pinch of sugar (1g per can) to match San Marzano sweetness; choose lower-acid plum tomato variety if possible.',
   'Lose: San Marzano signature low-acid sweet flavor from volcanic soil; AVPN authenticity claim. Gain: lower cost, universal availability. When appropriate: cost-tight operations. When NOT appropriate: any AVPN or Naples-style claim on the menu.',
   'high', 'stable'),
  ('san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 'san_marzano_style_us_grown_bianco_dinapoli_or_cento', 'vegetable_substance', 'Italian',
   'availability_swap', 'ingredient_swap', 0.85, 'cheaper', NULL,
   'Minimal adjustment needed; Bianco DiNapoli is widely respected.',
   'Lose: DOP certification and the volcanic-soil flavor specifically. Gain: very close flavor profile, US sourcing, better consistency than no-name plum tomato. When appropriate: middle-market positioning where DOP is too expensive but bottom-tier plum tomato is too far. When NOT appropriate: AVPN-certified or Naples-style imported menu claims.',
   'medium', 'stable'),
  ('basil_fresh_genovese', 'basil_fresh_mixed_varieties', 'aromatic_finishing', 'Italian',
   'availability_swap', 'ingredient_swap', 0.50, 'similar', NULL,
   'If only non-Genovese basil is available, omit basil from the bake and add post-bake garnish only.',
   'Lose: Genovese specific anise-clove character that defines Italian basil. Gain: nothing in margherita context. When appropriate: rarely; Genovese is the canonical variety. When NOT appropriate: most cases.',
   'low', 'approaching_peak'),
  ('flour_00_caputo_pizzeria_or_equivalent', 'flour_00_caputo_pizzeria_or_equivalent', 'dough_structure', 'Italian',
   'technique_simplification', 'technique_swap', 0.40, 'similar', 'bake_home_oven_with_steel_8_to_12_min_at_550F',
   'Preheat pizza steel 1+ hour at max oven temp (550F). Broil-blast last 1-2 min for top char.',
   'Lose: 60-90 second bake produces leoparded charred cornicione, blistered surface, soft puddly interior; home oven cannot replicate. Gain: dish becomes possible without wood-fired infrastructure. When appropriate: home cooking, food truck operators without pizza ovens, building MVP demos. When NOT appropriate: AVPN claim. The bake temperature IS part of the dish identity. A 550F bake is not a Neapolitan pizza.',
   'high', 'stable'),
  ('flour_00_caputo_pizzeria_or_equivalent', 'flour_00_caputo_pizzeria_or_equivalent', 'dough_structure', 'Italian',
   'availability_swap', 'technique_swap', 0.95, 'similar', 'bake_60_to_90_seconds_at_900F_gas_fired',
   'Same technique as wood-fired but using gas-fired Neapolitan oven.',
   'Lose: real wood smoke flavor (small but real). Gain: 850-900F bake achievable; 60-90 second cook times work; dish identity intact; mobile oven works for food truck. When appropriate: food truck operators serious about pizza margherita. When NOT appropriate: claiming wood-fired authenticity (flag honestly on menu as gas-fired Neapolitan).',
   'high', 'stable'),
  ('san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 'san_marzano_dop_whole_peeled_pomodoro_dellagro_sarnese_nocerino', 'vegetable_substance', 'Italian',
   'technique_simplification', 'technique_swap', 0.20, 'similar', NULL,
   'ENGINE WARNING: do NOT pre-cook the sauce for Neapolitan margherita.',
   'Anti-substitution flag. The 60-90 second oven bake at 900F cooks the raw tomato perfectly. Pre-cooking creates pasta-sauce flavor and over-reduces the tomato. This is one of the most common American errors. When appropriate: never for Neapolitan margherita. When NOT appropriate: always avoid. Compensate: just do not do it.',
   'high', 'stable'),
  ('flour_00_caputo_pizzeria_or_equivalent', 'flour_00_caputo_pizzeria_or_equivalent', 'dough_structure', 'Italian',
   'technique_simplification', 'technique_swap', 0.20, 'similar', NULL,
   'ENGINE WARNING: AVPN explicitly prohibits rolling pin for Neapolitan dough shaping.',
   'Anti-substitution flag. Rolling pin compresses the cornicione (puffy edge) and destroys the airy crumb structure that makes the dough Neapolitan. Hand-stretching preserves edge air pockets. When appropriate: never for Neapolitan margherita. When NOT appropriate: always avoid. Compensate: hand-stretch from center outward, leave edge thicker.',
   'high', 'stable')
) AS s(orig_canonical, sub_canonical, role_name, cuisine_name, purpose, kind, quality_score, cost_dir, alt_tech_name, technique_notes, tradeoff_notes, regional, seasonal)
JOIN ingredients orig ON orig.canonical_name = s.orig_canonical
JOIN ingredients sub ON sub.canonical_name = s.sub_canonical
JOIN ingredient_roles role ON role.name = s.role_name
JOIN cuisines cuis ON cuis.name = s.cuisine_name
LEFT JOIN techniques alt_tech ON alt_tech.name = s.alt_tech_name;

COMMIT;

-- ============================================================
-- VERIFICATION QUERIES (run after the transaction commits)
-- ============================================================

-- SELECT 't', 'count' FROM cooking_methods LIMIT 0;
-- SELECT 'cooking_methods' AS t, COUNT(*) AS row_count FROM cooking_methods
-- UNION ALL SELECT 'equipment', COUNT(*) FROM equipment
-- UNION ALL SELECT 'techniques', COUNT(*) FROM techniques
-- UNION ALL SELECT 'ingredient_categories', COUNT(*) FROM ingredient_categories
-- UNION ALL SELECT 'cuisines', COUNT(*) FROM cuisines
-- UNION ALL SELECT 'ingredients', COUNT(*) FROM ingredients
-- UNION ALL SELECT 'ingredient_aliases', COUNT(*) FROM ingredient_aliases
-- UNION ALL SELECT 'dishes', COUNT(*) FROM dishes
-- UNION ALL SELECT 'recipes', COUNT(*) FROM recipes
-- UNION ALL SELECT 'recipe_ingredients', COUNT(*) FROM recipe_ingredients
-- UNION ALL SELECT 'recipe_sub_recipes', COUNT(*) FROM recipe_sub_recipes
-- UNION ALL SELECT 'recipe_techniques', COUNT(*) FROM recipe_techniques
-- UNION ALL SELECT 'substitutions', COUNT(*) FROM substitutions
-- ORDER BY t;
--
-- Expected counts AFTER margherita seed (cumulative):
-- cooking_methods: 6
-- equipment: 31 (23 + 8)
-- techniques: 76 (54 + 22)
-- ingredient_categories: 7
-- cuisines: 3 (Vietnamese + Japanese + Italian)
-- ingredients: 107 (90 + 17 net new; some shared like fine_sea_salt already exist)
-- ingredient_aliases: 54 (39 + 15)
-- dishes: 3
-- recipes: 20 (15 + 5)
-- recipe_ingredients: ~120 (107 + ~13)
-- recipe_sub_recipes: 16 (12 + 4)
-- recipe_techniques: ~74 (51 + ~23)
-- substitutions: 35 (24 + 11)
--
-- Note: hand-counted estimates have proven unreliable; verify against actual database counts.
