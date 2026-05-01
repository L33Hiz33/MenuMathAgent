-- ============================================================
-- Seed: Pad thai (Bangkok street-style, Houston metro, April 2026)
-- Sixth real seed. v1.2 prompt with three-category substitution framework.
--
-- This is the first seed using migration 0006's substitution_classification
-- enum. All substitution rows include classification:
--   - real_substitution: 5 rows (valid swaps within dish identity)
--   - anti_pattern: 5 rows (documented errors with low quality_match_score
--                            and explicit warning notes)
--
-- Dish variants (pad see ew, pad woon sen, pad thai jay) NOT inserted as
-- substitutions per v1.2 rule. Flagged below for future dish_relationships
-- table when that work is scoped.
--
-- Provenance for ALL rows: llm_inferred_low_confidence
-- All inserts in a single transaction.
-- ============================================================

BEGIN;

-- ============================================================
-- EQUIPMENT (3 new rows)
-- ============================================================

INSERT INTO equipment (id, name, equipment_type, thermal_property_notes, max_practical_temp_f, description, provenance) VALUES
  (gen_random_uuid(), 'wok_carbon_steel_seasoned', 'vessel', 'Carbon steel wok seasoned over use; conducts heat rapidly; canonical for stir-fry.', 700, 'Traditional carbon steel wok for high-heat stir-fry; develops nonstick patina with seasoning.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'wok_burner_high_btu', 'heat_source', 'Restaurant-grade wok burner achieving 60,000+ BTU; home stoves rarely exceed 12,000 BTU.', 1000, 'High-BTU gas burner for wok-hei effect; produces carbonized-oil flavor unique to Asian stir-fry.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'mortar_and_pestle', 'vessel', NULL, NULL, 'Heavy stone mortar and pestle for crushing aromatics; modern kitchens often use food processor instead.', 'llm_inferred_low_confidence');

-- ============================================================
-- TECHNIQUES (17 new rows)
-- ============================================================

INSERT INTO techniques (id, name, method_id, primary_equipment_id, secondary_equipment_id, temperature_range_f, duration_range, difficulty_tier, notes, provenance)
SELECT gen_random_uuid(), t.name, cm.id, eq1.id, eq2.id, t.temp, t.duration, t.difficulty::technique_difficulty, t.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('stir_fry_high_heat_wok', 'fat_based', 'wok_carbon_steel_seasoned', 'wok_burner_high_btu'::text, '500-600', '4-5 min total', 'intermediate', 'Top-level pad thai technique. Wok must be at smoke point with rippling oil before food enters. Cook one portion at a time on home stoves to approximate restaurant wok-hei effect.'),
  ('dilute_tamarind_paste_with_hot_water', 'no_heat', 'mixing_bowl', NULL, NULL, '2 min', 'beginner', 'Mix pure tamarind paste with hot water until smooth pourable consistency.'),
  ('whisk_palm_sugar_into_warm_tamarind_until_dissolved', 'no_heat', 'mixing_bowl', NULL, NULL, '2 min', 'beginner', 'Whisk grated palm sugar into warm tamarind mixture until fully dissolved. Heat from tamarind helps dissolution.'),
  ('add_fish_sauce_combine_smooth', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'beginner', 'Whisk in fish sauce. Sauce should be uniformly smooth.'),
  ('adjust_balance_taste_test_for_4_balance', 'no_heat', 'mixing_bowl', NULL, NULL, '1 min', 'intermediate', 'Critical step. Taste sauce; adjust for four-balance: sour (tamarind), sweet (palm sugar), salty (fish sauce), and the eventual spicy contribution. Sour should dominate slightly with sweet and salty in balance. Dish defining.'),
  ('soak_dried_rice_noodles_in_warm_water_30_to_60min', 'no_heat', 'mixing_bowl', NULL, '110-120', '30-60 min', 'beginner', 'Soak in warm (NOT boiling) water until pliable but still firm. Will finish cooking in wok. Boiling produces mushy noodles; common American error.'),
  ('drain_noodles_thoroughly_before_stir_fry', 'no_heat', 'fine_mesh_strainer', NULL, NULL, '1 min', 'beginner', 'Drain very thoroughly. Excess water dilutes wok temperature and dilutes sauce concentration.'),
  ('heat_wok_to_smoke_point_high_btu', 'dry_heat', 'wok_carbon_steel_seasoned', 'wok_burner_high_btu', '500-600', '1-2 min', 'intermediate', 'Heat empty wok over highest possible flame. Wok should smoke when oil hits surface. Oil should ripple and shimmer on contact.'),
  ('add_oil_swirl_to_coat', 'fat_based', 'wok_carbon_steel_seasoned', NULL, '500', '5 sec', 'beginner', 'Add 2 tbsp neutral oil to hot wok, swirl to coat surface immediately.'),
  ('stir_fry_aromatics_15_to_30sec_garlic_shallot_dried_shrimp_preserved_radish', 'fat_based', 'wok_carbon_steel_seasoned', NULL, '500', '30 sec', 'intermediate', 'Add aromatics in quick succession. Stir constantly. Goal is fragrant, not browned. Burning these ruins the dish.'),
  ('add_protein_shrimp_tofu_60sec', 'fat_based', 'wok_carbon_steel_seasoned', NULL, '500', '60 sec', 'intermediate', 'Add fresh shrimp and tofu cubes. Toss until shrimp is just pink and tofu has slight color.'),
  ('push_aside_break_egg_into_wok', 'no_heat', 'wok_carbon_steel_seasoned', NULL, '500', '10 sec', 'beginner', 'Push protein and aromatics to one side of wok. Crack egg into the cleared space.'),
  ('scramble_egg_briefly_then_combine', 'fat_based', 'wok_carbon_steel_seasoned', NULL, '500', '30 sec', 'beginner', 'Scramble the egg in the cleared wok space until just set. Then combine with the protein and aromatics.'),
  ('add_drained_noodles_toss_to_combine', 'fat_based', 'wok_carbon_steel_seasoned', NULL, '500', '30 sec', 'intermediate', 'Add soaked-and-drained noodles. Toss with everything. Use two spatulas or wok tools.'),
  ('pour_pad_thai_sauce_over_noodles', 'no_heat', 'wok_carbon_steel_seasoned', NULL, '500', '5 sec', 'beginner', 'Pour pre-mixed sauce over noodles in wok. Move quickly to next step.'),
  ('toss_continuously_until_sauce_coats_evenly', 'fat_based', 'wok_carbon_steel_seasoned', NULL, '500', '60-90 sec', 'intermediate', 'Toss continuously. Sauce should coat noodles uniformly. Some caramelization on noodle edges is desired (wok-hei contribution). Do NOT let sauce burn.'),
  ('add_bean_sprouts_garlic_chives_off_heat', 'no_heat', 'wok_carbon_steel_seasoned', NULL, NULL, '15 sec', 'beginner', 'Remove wok from heat. Add bean sprouts and garlic chives. Toss briefly. Residual heat softens slightly without overcooking. Sprouts must stay crunchy.'),
  ('plate_immediately_with_garnishes', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'beginner', 'Plate immediately. Garnish with chopped peanuts, lime wedge, additional bean sprouts, garlic chives. Dried chili powder and white sugar on the side for diner adjustment.')
) AS t(name, method_name, primary_eq_name, secondary_eq_name, temp, duration, difficulty, notes)
JOIN cooking_methods cm ON cm.name = t.method_name
JOIN equipment eq1 ON eq1.name = t.primary_eq_name
LEFT JOIN equipment eq2 ON eq2.name = t.secondary_eq_name;

-- ============================================================
-- CUISINE (1 new row)
-- ============================================================

INSERT INTO cuisines (id, name, parent_id, region_bias, description, provenance) VALUES
  (gen_random_uuid(), 'Thai', NULL, 'Southeast Asia', 'Thai cuisine, encompassing strong regional sub-traditions: central Thai (Bangkok), northern Thai (Lanna/Chiang Mai), northeastern Thai (Isan), southern Thai. Distinct from Lao, Cambodian, and Vietnamese cuisines despite shared ingredients.', 'llm_inferred_low_confidence');

-- ============================================================
-- INGREDIENTS (~25 new rows)
-- ============================================================

INSERT INTO ingredients (id, canonical_name, display_name, category_id, subcategory_id, default_unit, usda_commodity_code, description, provenance)
SELECT gen_random_uuid(), i.canonical_name, i.display_name, cat.id, NULL, i.default_unit, NULL, i.description, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  -- Rice noodles
  ('rice_noodles_sen_lek_dried_thai', 'Rice noodles, sen lek (flat, medium width, dried, Thai)', 'pantry', 'g', 'Flat dried rice noodles 3-5mm wide. Specifically pad thai cut. Erawan or Three Ladies brand most widely distributed.'),
  ('rice_noodles_sen_yai_dried_thai', 'Rice noodles, sen yai (flat, wide, dried, Thai)', 'pantry', 'g', 'Wide flat rice noodles for pad see ew, NOT pad thai. Listed for dish_variant reference.'),
  ('glass_noodles_woon_sen_mung_bean_dried', 'Glass noodles (woon sen, mung bean, dried)', 'pantry', 'g', 'Translucent mung bean starch noodles for pad woon sen, NOT pad thai. Listed for dish_variant reference.'),
  -- Sauce ingredients
  ('tamarind_paste_pure_thai_por_kwan', 'Tamarind paste, pure (Por Kwan or Thai Choice brand)', 'pantry', 'g', 'Pure tamarind paste from Thai brand. Distinct from tamarind concentrate which is much stronger. Premium tier: Por Kwan.'),
  ('tamarind_concentrate', 'Tamarind concentrate', 'pantry', 'g', 'Concentrated tamarind extract. Use 1/3 weight of paste, dilute 1:3 with warm water.'),
  ('palm_sugar_nam_tan_peep_thai', 'Palm sugar (nam tan peep, Thai)', 'pantry', 'g', 'Thai palm sugar with caramel-vanilla notes; distinct from Vietnamese palm sugar in profile. Sold in solid pucks; grate before use.'),
  ('fish_sauce_premium_thai_squid_or_three_crabs', 'Fish sauce, premium Thai (Squid Brand or Three Crabs Thai variant)', 'sauces_and_condiments', 'ml', 'Thai fish sauce; lighter and slightly sweeter than Vietnamese fish sauce profile.'),
  -- Aromatics specific to pad thai
  ('shallot_finely_sliced', 'Shallot, finely sliced', 'vegetables', 'g', 'Fresh shallot cut into thin slices for quick wok cook. Used in pad thai stir-fry.'),
  ('preserved_radish_chai_poh_thai', 'Preserved radish (chai poh, Thai)', 'sauces_and_condiments', 'g', 'Salted-fermented dried daikon radish, chopped. Critical pad thai ingredient providing salt-funk fermented depth. Most American pad thai skips this; result is recognizably less complex.'),
  ('dried_shrimp_kung_haeng_small_thai', 'Dried shrimp (kung haeng, small, Thai)', 'proteins', 'g', 'Tiny dried whole shrimp. Critical pad thai ingredient providing umami salt-funk foundation. Often skipped in American versions; result tastes flat.'),
  ('shrimp_fresh_or_frozen_16_20_count', 'Shrimp, fresh or frozen, 16-20 count', 'proteins', 'g', 'Medium-size shrimp peeled and deveined. Houston Gulf coast access; April-July is peak season.'),
  ('tofu_extra_firm_pressed_cubed', 'Tofu, extra-firm, pressed, cubed (1cm)', 'proteins', 'g', 'Pressed extra-firm tofu cubed for stir-fry. Standard pad thai uses BOTH shrimp and tofu, not either-or.'),
  ('eggs_large_for_stir_fry', 'Eggs, large (for stir-fry)', 'dairy', 'each', 'Large fresh eggs broken directly into wok during stir-fry.'),
  -- Garnish specific
  ('roasted_peanuts_unsalted_chopped', 'Roasted peanuts, unsalted, coarsely chopped', 'pantry', 'g', 'Unsalted roasted peanuts for garnish. Moderate amount; over-peanutting is American error.'),
  ('lime_fresh', 'Lime, fresh', 'vegetables', 'each', 'Fresh lime. Cut into wedges for service; squeezed by diner at table.'),
  ('bean_sprouts_fresh_mung_bean', 'Bean sprouts, fresh (mung bean)', 'vegetables', 'g', 'Fresh mung bean sprouts. Added off-heat or as raw garnish. Must stay crunchy.'),
  ('garlic_chives_kuchai_thai', 'Garlic chives (kuchai, Thai)', 'vegetables', 'g', 'Flat broad-leaf chives with garlic-onion-grass character. NOT regular green onion. Distinct flavor profile.'),
  ('dried_chili_powder_prik_pon_thai', 'Dried chili powder (prik pon, Thai)', 'pantry', 'g', 'Thai dried chili powder. Served on side for diner adjustment, traditional Thai serving style. Korean gochugaru is acceptable substitute (different profile).'),
  -- Substitute ingredients (real_substitutions)
  ('chicken_thigh_for_pad_thai_gai', 'Chicken thigh, for pad thai gai', 'proteins', 'g', 'Thinly sliced chicken thigh for pad thai gai variant. Marinade in fish sauce 15 min before wok cook.'),
  ('brown_sugar_for_palm_substitute', 'Brown sugar (substitute for palm sugar)', 'pantry', 'g', 'Brown sugar as cost-down substitute for palm sugar in pad thai sauce. Add 1/4 tsp molasses to compensate for missing caramel-vanilla notes.'),
  ('vegetarian_fish_sauce_thai', 'Vegetarian fish sauce (Thai-style)', 'sauces_and_condiments', 'ml', 'Plant-based fish sauce alternative for vegetarian/vegan pad thai. Made from soy, mushroom, seaweed.'),
  ('white_miso_paste_for_umami', 'White miso paste (for vegetarian umami)', 'sauces_and_condiments', 'g', 'Light fermented soybean paste; vegetarian umami source for pad thai when dried shrimp removed.'),
  -- Anti-pattern reference (ketchup; exists for substitutions classification)
  ('ketchup_anti_pattern_reference', 'Ketchup (anti-pattern reference for pad thai)', 'sauces_and_condiments', 'g', 'Tomato ketchup. Listed in substitutions table as anti_pattern reference for tamarind-paste substitution warning. Different flavor profile entirely from tamarind.')
) AS i(canonical_name, display_name, category_name, default_unit, description)
JOIN ingredient_categories cat ON cat.name = i.category_name;

-- ============================================================
-- INGREDIENT ALIASES (Thai-English)
-- ============================================================

INSERT INTO ingredient_aliases (id, ingredient_id, alias_name, language, region_origin, notes, provenance)
SELECT gen_random_uuid(), ing.id, a.alias_name, a.language, a.region_origin, a.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('rice_noodles_sen_lek_dried_thai', 'sen lek', 'th', 'Thailand', 'Thai name for medium-flat pad thai noodles.'),
  ('rice_noodles_sen_lek_dried_thai', 'pad thai noodles', 'en', 'common usage', 'Common English description.'),
  ('rice_noodles_sen_yai_dried_thai', 'sen yai', 'th', 'Thailand', 'Thai name for wide rice noodles for pad see ew.'),
  ('glass_noodles_woon_sen_mung_bean_dried', 'woon sen', 'th', 'Thailand', 'Thai name for mung bean glass noodles.'),
  ('glass_noodles_woon_sen_mung_bean_dried', 'cellophane noodles', 'en', 'common usage', 'English description; same noodle.'),
  ('tamarind_paste_pure_thai_por_kwan', 'makham piak', 'th', 'Thailand', 'Thai name for pure tamarind paste.'),
  ('palm_sugar_nam_tan_peep_thai', 'nam tan peep', 'th', 'Thailand', 'Thai name for palm sugar.'),
  ('palm_sugar_nam_tan_peep_thai', 'jaggery', 'en', 'South Asia', 'Generic English/South Asian term sometimes used; not exactly the same product.'),
  ('preserved_radish_chai_poh_thai', 'chai poh', 'th', 'Thailand', 'Thai name; from Teochew Chinese origin.'),
  ('preserved_radish_chai_poh_thai', 'salted preserved radish', 'en', 'global', 'English description.'),
  ('dried_shrimp_kung_haeng_small_thai', 'kung haeng', 'th', 'Thailand', 'Thai name for dried shrimp.'),
  ('garlic_chives_kuchai_thai', 'kuchai', 'th', 'Thailand', 'Thai name (from Cantonese gau choi).'),
  ('garlic_chives_kuchai_thai', 'Chinese chives', 'en', 'common usage', 'Alternate English name.'),
  ('dried_chili_powder_prik_pon_thai', 'prik pon', 'th', 'Thailand', 'Thai name for dried chili flakes.'),
  ('shrimp_fresh_or_frozen_16_20_count', 'kung sod', 'th', 'Thailand', 'Thai name for fresh shrimp.')
) AS a(canonical_name, alias_name, language, region_origin, notes)
JOIN ingredients ing ON ing.canonical_name = a.canonical_name;

-- ============================================================
-- DISH (1 new row)
-- ============================================================

INSERT INTO dishes (id, name, cuisine_id, archetype_id, description, complexity_tier, provenance)
SELECT gen_random_uuid(), 'Pad thai (Bangkok street-style)', c.id, NULL,
  'Bangkok street-style pad thai. Sen lek rice noodles soaked (NOT boiled), stir-fried in carbon steel wok at very high heat with shallot, garlic, preserved radish (chai poh), dried shrimp (kung haeng), fresh shrimp, extra-firm tofu, scrambled egg. Sauced with tamarind-palm sugar-fish sauce four-balance (sour-sweet-salty-spicy). Garnished with bean sprouts, garlic chives (kuchai), chopped peanuts, lime wedge. Served with dried chili powder and white sugar on side for diner four-balance adjustment. Dish defined by four-balance principle; the sauce ratio defines the dish.',
  'intermediate'::complexity_tier, 'llm_inferred_low_confidence'::provenance_type
FROM cuisines c WHERE c.name = 'Thai';

-- ============================================================
-- RECIPES (5 rows: 1 parent + 4 sub-recipes)
-- ============================================================

INSERT INTO recipes (id, dish_id, title, source, source_url, instructions, yield_quantity, yield_unit, complexity_tier, submitted_by_user_id, provenance, validity_window_end_date)
SELECT gen_random_uuid(), d.id, r.title, r.source, NULL, r.instructions, r.yield_qty, r.yield_unit, r.complexity::complexity_tier, NULL, 'llm_inferred_low_confidence'::provenance_type, r.validity_end::date
FROM (VALUES
  ('Pad thai (Bangkok street-style, Houston metro April 2026)', 'Engine B v1.2 decomposition', 'Soak sen lek rice noodles in warm water 30-60 min until pliable but firm. Drain thoroughly. Heat wok to smoke point. Add oil, then aromatics (shallot, garlic, preserved radish, dried shrimp) 30 sec. Add fresh shrimp and tofu 60 sec. Push aside, scramble egg in cleared space, combine. Add drained noodles, toss. Pour sauce over, toss continuously 60-90 sec until evenly coated. Off heat, add bean sprouts and garlic chives. Plate immediately with chopped peanuts, lime wedge, dried chili powder and sugar on side.', 1, 'plate', 'intermediate', '2026-06-30'),
  ('Pad thai sauce (four-balance core)', 'Engine B v1.2 decomposition', 'Dilute tamarind paste with hot water until smooth. Whisk in palm sugar until dissolved. Add fish sauce. Taste and adjust for four-balance: sour-sweet-salty-spicy ratio. Sour should slightly dominate. Sauce should be thick enough to coat noodles but pourable.', 80, 'ml', 'intermediate', NULL),
  ('Rice noodles (sen lek, soaked)', 'Engine B v1.2 decomposition', 'Place dried sen lek rice noodles in large bowl. Cover with WARM (110-120F) water. Soak 30-60 min until pliable but still firm. Do NOT use boiling water. Drain very thoroughly before stir-fry; excess water dilutes wok temperature.', 200, 'g', 'basic_prep', NULL),
  ('Aromatics-and-protein base for stir-fry', 'Engine B v1.2 decomposition', 'Prepare all components ready at wok-side: thinly sliced shallot, finely minced garlic, chopped preserved radish, dried shrimp, peeled fresh shrimp, cubed pressed tofu, eggs in shell. Stir-fry at high heat in sequence: aromatics 30 sec, protein 60 sec, scramble egg, combine.', 1, 'plate_serving', 'intermediate', NULL),
  ('Garnish (peanut, lime, chili, herbs)', 'Engine B v1.2 decomposition', 'Coarsely chop roasted peanuts. Cut lime into wedges. Wash bean sprouts. Cut garlic chives into 2-inch lengths. Place chili powder and white sugar in small ramekins for table service.', 1, 'plate_garnish', 'basic_prep', NULL)
) AS r(title, source, instructions, yield_qty, yield_unit, complexity, validity_end)
LEFT JOIN dishes d ON d.name = 'Pad thai (Bangkok street-style)' AND r.title LIKE 'Pad thai%';

-- ============================================================
-- RECIPE_INGREDIENTS
-- ============================================================

-- Pad thai sauce sub-recipe
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('tamarind_paste_pure_thai_por_kwan', 60::numeric, 'g', NULL::text, 'acid', 'Pure paste, NOT concentrate.'::text),
  ('palm_sugar_nam_tan_peep_thai', 60, 'g', 'grated', 'sweetener', 'Thai palm sugar caramel-vanilla notes.'),
  ('fish_sauce_premium_thai_squid_or_three_crabs', 45, 'ml', NULL, 'umami_base', 'Premium Thai brand for cleanest umami.'),
  ('water', 15, 'ml', 'hot, for diluting tamarind', 'cooking_liquid', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Pad thai sauce (four-balance core)';

-- Rice noodles sub-recipe
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('rice_noodles_sen_lek_dried_thai', 80::numeric, 'g', 'soaked in warm water 30-60 min, drained thoroughly'::text, 'starch_base', 'Sen lek specifically; sen yai is for pad see ew, woon sen for pad woon sen.'::text),
  ('water', 1000, 'ml', 'warm, 110-120F for soaking', 'cooking_liquid', 'Do NOT use boiling water.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Rice noodles (sen lek, soaked)';

-- Aromatics-and-protein base sub-recipe
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('shallot_finely_sliced', 30::numeric, 'g', 'thinly sliced'::text, 'aromatic_base', NULL::text),
  ('garlic_minced', 15, 'g', 'finely minced', 'aromatic_base', NULL),
  ('preserved_radish_chai_poh_thai', 15, 'g', 'chopped fine', 'pickle_component', 'Critical ingredient. Salt-funk fermented depth.'),
  ('dried_shrimp_kung_haeng_small_thai', 10, 'g', 'small whole', 'secondary_protein', 'Critical ingredient. Umami foundation.'),
  ('shrimp_fresh_or_frozen_16_20_count', 100, 'g', 'peeled and deveined', 'primary_protein', 'Houston Gulf coast access; April-July peak.'),
  ('tofu_extra_firm_pressed_cubed', 60, 'g', 'pressed and cubed 1cm, patted dry', 'primary_protein', 'Standard pad thai uses BOTH shrimp and tofu.'),
  ('eggs_large_for_stir_fry', 1, 'each', 'broken directly into wok', 'secondary_protein', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Aromatics-and-protein base for stir-fry';

-- Garnish sub-recipe
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('roasted_peanuts_unsalted_chopped', 15::numeric, 'g', 'coarsely chopped'::text, 'texture_crunch', false, 'Garnish, not mixed in.'::text),
  ('lime_fresh', 1, 'each', 'cut into wedges', 'acid', false, 'Squeezed by diner at table.'),
  ('bean_sprouts_fresh_mung_bean', 50, 'g', 'fresh', 'vegetable_substance', false, 'Added off-heat or as raw garnish; stays crunchy.'),
  ('garlic_chives_kuchai_thai', 30, 'g', 'cut 2-inch lengths', 'aromatic_finishing', false, 'Kuchai specifically; not green onion.'),
  ('dried_chili_powder_prik_pon_thai', 1.5, 'g', 'served on side', 'heat_component', true, 'Optional; traditional table-side for diner adjustment.'),
  ('sugar_white_granulated', 2, 'g', 'served on side', 'sweetener', true, 'Optional; traditional table-side for diner four-balance adjustment.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Garnish (peanut, lime, chili, herbs)';

-- ============================================================
-- RECIPE_SUB_RECIPES
-- ============================================================

INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, link.qty, link.unit, link.step_order, false, link.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Pad thai (Bangkok street-style, Houston metro April 2026)', 'Pad thai sauce (four-balance core)', 'sauce_body', 80::numeric, 'ml', 1, 'Prepared in advance.'::text),
  ('Pad thai (Bangkok street-style, Houston metro April 2026)', 'Rice noodles (sen lek, soaked)', 'starch_base', 200, 'g', 2, 'Soaked 30-60 min before stir-fry.'),
  ('Pad thai (Bangkok street-style, Houston metro April 2026)', 'Aromatics-and-protein base for stir-fry', 'primary_protein', 230, 'g', 3, 'Wok stir-fry sequence.'),
  ('Pad thai (Bangkok street-style, Houston metro April 2026)', 'Garnish (peanut, lime, chili, herbs)', 'aromatic_finishing', 100, 'g', 4, 'Plated and table-side.')
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
  -- Parent recipe
  ('Pad thai (Bangkok street-style, Houston metro April 2026)', 'stir_fry_high_heat_wok', 1, 'Top-level execution.'::text),
  -- Sauce sub-recipe
  ('Pad thai sauce (four-balance core)', 'dilute_tamarind_paste_with_hot_water', 1, NULL),
  ('Pad thai sauce (four-balance core)', 'whisk_palm_sugar_into_warm_tamarind_until_dissolved', 2, NULL),
  ('Pad thai sauce (four-balance core)', 'add_fish_sauce_combine_smooth', 3, NULL),
  ('Pad thai sauce (four-balance core)', 'adjust_balance_taste_test_for_4_balance', 4, 'Critical step. Sour should slightly dominate.'),
  -- Noodles sub-recipe
  ('Rice noodles (sen lek, soaked)', 'soak_dried_rice_noodles_in_warm_water_30_to_60min', 1, 'Warm water, NOT boiling.'),
  ('Rice noodles (sen lek, soaked)', 'drain_noodles_thoroughly_before_stir_fry', 2, NULL),
  -- Aromatics-and-protein sub-recipe
  ('Aromatics-and-protein base for stir-fry', 'heat_wok_to_smoke_point_high_btu', 1, NULL),
  ('Aromatics-and-protein base for stir-fry', 'add_oil_swirl_to_coat', 2, NULL),
  ('Aromatics-and-protein base for stir-fry', 'stir_fry_aromatics_15_to_30sec_garlic_shallot_dried_shrimp_preserved_radish', 3, NULL),
  ('Aromatics-and-protein base for stir-fry', 'add_protein_shrimp_tofu_60sec', 4, NULL),
  ('Aromatics-and-protein base for stir-fry', 'push_aside_break_egg_into_wok', 5, NULL),
  ('Aromatics-and-protein base for stir-fry', 'scramble_egg_briefly_then_combine', 6, NULL),
  ('Aromatics-and-protein base for stir-fry', 'add_drained_noodles_toss_to_combine', 7, NULL),
  ('Aromatics-and-protein base for stir-fry', 'pour_pad_thai_sauce_over_noodles', 8, NULL),
  ('Aromatics-and-protein base for stir-fry', 'toss_continuously_until_sauce_coats_evenly', 9, NULL),
  ('Aromatics-and-protein base for stir-fry', 'add_bean_sprouts_garlic_chives_off_heat', 10, NULL),
  ('Aromatics-and-protein base for stir-fry', 'plate_immediately_with_garnishes', 11, NULL)
) AS rt(recipe_title, technique_name, step_order, notes)
JOIN recipes r ON r.title = rt.recipe_title
JOIN techniques t ON t.name = rt.technique_name;

-- ============================================================
-- SUBSTITUTIONS (5 real_substitutions + 5 anti_patterns = 10 rows)
-- v1.2 first seed using substitution_classification column
-- ============================================================

INSERT INTO substitutions (id, original_ingredient_id, substitute_ingredient_id, role_id, cuisine_id, substitution_purpose, substitution_kind, alternative_technique_id, quality_match_score, cost_direction, technique_adjustment_notes, notes, verified_by_user_id, provenance, regional_weight, seasonal_weight, classification)
SELECT gen_random_uuid(),
       orig.id, sub.id, role.id, cuis.id,
       s.purpose::substitution_purpose, s.kind::substitution_kind,
       alt_tech.id,
       s.quality_score, s.cost_dir::cost_direction,
       s.technique_notes, s.tradeoff_notes,
       NULL::uuid,
       'llm_inferred_low_confidence'::provenance_type,
       s.regional::regional_weight_tier,
       s.seasonal::seasonal_weight_tier,
       s.classif::substitution_classification
FROM (VALUES
  -- ============================================================
  -- REAL_SUBSTITUTIONS (5 rows)
  -- ============================================================
  -- 1. Shrimp -> chicken thigh (pad thai gai)
  ('shrimp_fresh_or_frozen_16_20_count', 'chicken_thigh_for_pad_thai_gai', 'primary_protein', 'Thai',
   'dietary_restriction', 'ingredient_swap', 0.65::numeric, 'cheaper', NULL::text,
   'Marinate chicken thigh 15 min in 1 tsp fish sauce; thinly sliced; brief wok cook.',
   'Lose: shrimp specific brininess that pairs with dried shrimp umami. Gain: poultry option, lower cost, halal compatible. When appropriate: pad thai gai menu item, halal positioning. When NOT appropriate: claiming "traditional pad thai" without qualifier.',
   'high', 'stable', 'real_substitution'),
  -- 2. Shrimp + tofu -> tofu only (vegetarian)
  ('shrimp_fresh_or_frozen_16_20_count', 'tofu_extra_firm_pressed_cubed', 'primary_protein', 'Thai',
   'dietary_restriction', 'ingredient_swap', 0.55, 'cheaper', NULL,
   'Increase tofu volume; use vegetarian fish sauce; add 1 tsp white miso for missing umami; add 1 tsp soy sauce; chopped roasted cashews for richness.',
   'Lose: shrimp protein; dried shrimp must also be removed (further reduces umami). Gain: vegetarian option. When appropriate: vegetarian/vegan menu position. When NOT appropriate: claiming "traditional pad thai"; the dish is structurally non-vegetarian.',
   'high', 'stable', 'real_substitution'),
  -- 3. Tamarind paste pure -> tamarind concentrate
  ('tamarind_paste_pure_thai_por_kwan', 'tamarind_concentrate', 'acid', 'Thai',
   'availability_swap', 'ingredient_swap', 0.90, 'similar', NULL,
   'Use 1/3 the weight of paste; dilute 1:3 with warm water before measuring.',
   'Lose: nothing meaningful when used correctly. Gain: longer shelf life, more concentrated. When appropriate: when paste is unavailable. When NOT appropriate: when recipe specifies pure paste with specific quantity.',
   'low', 'stable', 'real_substitution'),
  -- 4. Palm sugar -> brown sugar
  ('palm_sugar_nam_tan_peep_thai', 'brown_sugar_for_palm_substitute', 'sweetener', 'Thai',
   'cost_reduction', 'ingredient_swap', 0.70, 'cheaper', NULL,
   'Use slightly less brown sugar; add 1/4 tsp molasses for depth.',
   'Lose: palm sugar caramel-vanilla notes. Gain: cost, universal availability. When appropriate: cost-conscious operations. When NOT appropriate: high-end Thai positioning.',
   'low', 'stable', 'real_substitution'),
  -- 5. Premium fish sauce -> Standard fish sauce (cost down)
  ('fish_sauce_premium_thai_squid_or_three_crabs', 'fish_sauce_premium_red_boat_or_3_crabs', 'umami_base', 'Thai',
   'cost_reduction', 'ingredient_swap', 0.85, 'cheaper', NULL, NULL,
   'Lose: marginal flavor cleanness. Gain: lower cost. Compensate: any premium Thai or Vietnamese fish sauce is acceptable; standard grocery brands have less depth. When appropriate: cost-conscious operations. When NOT appropriate: high-end Thai positioning where fish sauce is part of food story.',
   'medium', 'stable', 'real_substitution'),
  -- ============================================================
  -- ANTI_PATTERNS (5 rows)
  -- Quality match score 0.00-0.20; explicit WARNING notes
  -- ============================================================
  -- A1. Tamarind paste -> ketchup (the dish-defining anti-pattern)
  ('tamarind_paste_pure_thai_por_kwan', 'ketchup_anti_pattern_reference', 'acid', 'Thai',
   'technique_simplification', 'ingredient_swap', 0.10, 'similar', NULL,
   'WARNING: ketchup is NOT a substitute for tamarind paste in pad thai.',
   'ANTI-PATTERN. Flavor profile distance >50% in role context. Tamarind: sweet 2, sour 7, salty 1, umami 1, fruity 6 (tropical/dried-fruit). Ketchup: sweet 5, sour 4, salty 3, umami 4, fruity 3 (tomato). Different profile entirely. American counterfeit error. Substituting changes the dish to something that is not pad thai. If tamarind genuinely unavailable, partial compensation: lime juice + brown sugar + tiny bit of Worcestershire (still imperfect; do not call it pad thai).',
   'low', 'stable', 'anti_pattern'),
  -- A2. Skipping preserved radish (chai poh)
  ('preserved_radish_chai_poh_thai', 'preserved_radish_chai_poh_thai', 'pickle_component', 'Thai',
   'technique_simplification', 'ingredient_swap', 0.05, 'cheaper', NULL,
   'WARNING: skipping preserved radish removes a defining flavor.',
   'ANTI-PATTERN. Most American pad thai skips chai poh; result is recognizably less complex. Provides salt-funk fermented depth that grounds the dish. If genuinely unavailable, partial compensation: 1 tsp soy sauce + pinch of salt (does not replicate). Quality match score 0.05 reflects that this "substitute" (skipping) destroys the dish identity.',
   'medium', 'stable', 'anti_pattern'),
  -- A3. Skipping dried shrimp (kung haeng)
  ('dried_shrimp_kung_haeng_small_thai', 'dried_shrimp_kung_haeng_small_thai', 'secondary_protein', 'Thai',
   'technique_simplification', 'ingredient_swap', 0.05, 'cheaper', NULL,
   'WARNING: skipping dried shrimp removes the umami foundation.',
   'ANTI-PATTERN. Most American pad thai skips kung haeng; result tastes flat. Provides salt-funk umami foundation. If unavailable, partial compensation: 1 anchovy fillet finely minced (still imperfect; profile differs). Quality match score 0.05 reflects that "skipping" is not a valid substitution.',
   'medium', 'stable', 'anti_pattern'),
  -- A4. Boiling rice noodles (technique anti-pattern)
  ('rice_noodles_sen_lek_dried_thai', 'rice_noodles_sen_lek_dried_thai', 'starch_base', 'Thai',
   'technique_simplification', 'technique_swap', 0.10, 'similar', NULL,
   'WARNING: boiling rice noodles produces mushy overcooked noodles.',
   'ANTI-PATTERN. Pad thai noodles must be SOAKED in warm water 30-60 min, NOT boiled. The wok stir-fry finishes the cook. Boiling is the most common American error. Quality match score 0.10 reflects that this is a destructive technique substitution.',
   'high', 'stable', 'anti_pattern'),
  -- A5. Garlic chives -> green onion (boundary case, leans anti-pattern)
  ('garlic_chives_kuchai_thai', 'green_onion_thin_sliced', 'aromatic_finishing', 'Thai',
   'availability_swap', 'ingredient_swap', 0.30, 'similar', NULL,
   'WARNING: garlic chives are kuchai specifically; green onion has different flavor profile.',
   'ANTI-PATTERN (boundary case). Garlic chives have garlic-onion-grass character; green onion has milder onion-only character (no garlic note). Different aroma family weighting. In Houston where kuchai is abundant at H Mart and Hong Kong Food Market, this swap is unnecessary. Listed as anti-pattern when authenticity matters. Could become marginal real_substitution in regions where kuchai unavailable; handle with judgment.',
   'low', 'stable', 'anti_pattern')
) AS s(orig_canonical, sub_canonical, role_name, cuisine_name, purpose, kind, quality_score, cost_dir, alt_tech_name, technique_notes, tradeoff_notes, regional, seasonal, classif)
JOIN ingredients orig ON orig.canonical_name = s.orig_canonical
JOIN ingredients sub ON sub.canonical_name = s.sub_canonical
JOIN ingredient_roles role ON role.name = s.role_name
JOIN cuisines cuis ON cuis.name = s.cuisine_name
LEFT JOIN techniques alt_tech ON alt_tech.name = s.alt_tech_name;

COMMIT;

-- ============================================================
-- DISH_VARIANTS NOT INSERTED (per v1.2 rule)
--
-- The following are flagged for future dish_relationships table seeding:
--
-- V1: Sen lek -> Sen yai = pad see ew (different dish)
-- V2: Sen lek -> Woon sen = pad woon sen (different dish)
-- V3: Strict Buddhist vegetarian = pad thai jay (different dish; no garlic/onion)
--
-- These are NOT substitutions per v1.2 classification framework.
-- They produce different dishes, not variants of pad thai.
-- Will be seeded to dish_relationships table when that work is scoped.
-- ============================================================

-- ============================================================
-- VERIFICATION QUERIES (run after the transaction commits)
-- ============================================================

-- SELECT 'cooking_methods' AS t, COUNT(*) AS row_count FROM cooking_methods
-- UNION ALL SELECT 'equipment', COUNT(*) FROM equipment
-- UNION ALL SELECT 'techniques', COUNT(*) FROM techniques
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
-- Approximate cumulative expected (banh mi + tonkotsu + margherita + cheeseburger + carnitas + pad thai):
-- cooking_methods: 6
-- cuisines: 6 (Vietnamese, Japanese, Italian, American, Mexican, Thai)
-- dishes: 6
-- equipment: 45 (42 + 3)
-- techniques: ~122 (105 + 17)
-- ingredients: ~182 (157 + ~25)
-- ingredient_aliases: ~96 (81 + ~15)
-- recipes: 35 (30 + 5)
-- recipe_sub_recipes: 28 (24 + 4)
-- substitutions: 67 (57 + 10)
--
-- v1.2-specific verification (substitutions classification):
-- SELECT classification, COUNT(*) FROM substitutions GROUP BY classification ORDER BY classification;
-- Expected after this seed:
--   real_substitution: 5
--   anti_pattern: 5
--   NULL: 57 (pre-v1.2 rows from earlier seeds)
