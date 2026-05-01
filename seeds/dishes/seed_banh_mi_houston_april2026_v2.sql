-- ============================================================
-- Seed: Banh mi (Saigon-style, Houston metro, April 2026)
-- First real seed via Engine B output. CORRECTED VERSION.
--
-- Changes from prior version:
--   - Added 9 substitute ingredients to ingredients block
--   - Removed WHERE clause that silently skipped substitution rows
--   - All 11 substitutions now expected to seed
--
-- Provenance for ALL rows: llm_inferred_low_confidence
-- All rows await human review and promotion.
--
-- FK dependency order:
--   cooking_methods -> equipment -> techniques
--   -> ingredient_categories -> cuisines
--   -> ingredients -> ingredient_aliases
--   -> dishes -> recipes
--   -> recipe_ingredients, recipe_sub_recipes, recipe_techniques
--   -> substitutions
--
-- All inserts in a single transaction. Either all lands or none.
--
-- Run after: migration 0005 applied (regional_weight, seasonal_weight,
-- validity_window_end_date columns exist).
-- ============================================================

BEGIN;

-- ============================================================
-- COOKING METHODS (6 rows)
-- ============================================================

INSERT INTO cooking_methods (id, name, category, description, provenance) VALUES
  (gen_random_uuid(), 'fermentation', 'fermentation', 'Microbial transformation of food via yeast, bacteria, or mold.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'dry_heat', 'dry_heat', 'Cooking via heated air or radiation without added moisture.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'moist_heat', 'moist_heat', 'Cooking via water, steam, or stock as primary heat carrier.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'combination', 'combination', 'Sequential dry and moist heat application (braise, water bath, etc.).', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'fat_based', 'fat_based', 'Cooking with fat as primary heat carrier (saute, fry, confit).', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'no_heat', 'no_heat', 'Preparation without heat application (chopping, mixing, marinating, emulsifying).', 'llm_inferred_low_confidence');

-- ============================================================
-- EQUIPMENT (13 rows)
-- ============================================================

INSERT INTO equipment (id, name, equipment_type, thermal_property_notes, max_practical_temp_f, description, provenance) VALUES
  (gen_random_uuid(), 'proofing_container', 'vessel', 'Lidded vessel holding ambient or controlled temp dough.', 100, 'Container for dough fermentation, ambient or controlled temp.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'deck_oven_steam_injection', 'appliance', 'Commercial bakery oven with built-in steam injection for crust development.', 550, 'Commercial-grade deck oven with steam injection capability.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'bakers_peel', 'tool', NULL, NULL, 'Wooden or metal paddle for moving loaves.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'domestic_oven_with_water_pan', 'appliance', 'Standard home oven with water-filled tray on lower rack to approximate steam injection.', 500, 'Home oven plus water pan for steam approximation.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'whisk', 'tool', NULL, NULL, 'Hand whisk for emulsification and aeration.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'saute_pan', 'vessel', 'Heavy-bottomed pan with sloped sides for sauteing.', 500, 'Stainless or cast iron pan, sloped sides.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'food_processor', 'appliance', NULL, NULL, 'Bowl-and-blade processor for chopping, blending, pureeing.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'terrine_mold', 'vessel', 'Loaf-shaped baking dish for pates and terrines.', 350, 'Ceramic or enameled cast iron loaf form for terrines.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'water_bath_setup', 'vessel', 'Outer pan filled with hot water surrounding inner cooking vessel.', 200, 'Bain-marie setup for gentle even baking.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'charcoal_grill', 'heat_source', 'Open-flame charcoal heat source contributing direct radiant heat and smoke.', 900, 'Charcoal grill, direct or indirect heat.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'broiler', 'heat_source', 'Top-element radiant heat source in oven.', 550, 'Oven broiler element for direct radiant heat from above.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'mixing_bowl', 'vessel', NULL, NULL, 'Bowl for combining ingredients.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'chef_knife', 'tool', NULL, NULL, 'Primary cutting tool, 8 to 10 inch blade.', 'llm_inferred_low_confidence');

-- ============================================================
-- TECHNIQUES (20 rows, FK to cooking_methods + equipment)
-- ============================================================

INSERT INTO techniques (id, name, method_id, primary_equipment_id, secondary_equipment_id, temperature_range_f, duration_range, difficulty_tier, notes, provenance)
SELECT gen_random_uuid(), t.name, cm.id, eq1.id, eq2.id, t.temp, t.duration, t.difficulty::technique_difficulty, t.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('assembly_layered_sandwich', 'no_heat', 'chef_knife', NULL::text, NULL::text, '5-10 min', 'beginner', 'Layer order matters for moisture management; pate first, mayo second, protein third, pickle fourth, herbs and chiles last.'),
  ('bulk_ferment_room_temp', 'fermentation', 'proofing_container', NULL, '70-78', '1-2 hours', 'beginner', 'Ambient temperature affects timing significantly; warmer kitchen = faster ferment.'),
  ('cold_proof_overnight', 'fermentation', 'proofing_container', NULL, '38-42', '8-16 hours', 'beginner', 'Develops flavor and improves crumb structure.'),
  ('steam_injected_bake', 'dry_heat', 'deck_oven_steam_injection', 'bakers_peel', '460-475', '18-22 min', 'advanced', 'Home oven cannot fully replicate; substitute domestic_steam_pan_bake.'),
  ('domestic_steam_pan_bake', 'dry_heat', 'domestic_oven_with_water_pan', 'bakers_peel', '475-500', '20-25 min', 'intermediate', 'Substitute for steam_injected_bake; place water tray on lower rack.'),
  ('cold_emulsion_whisked', 'no_heat', 'whisk', 'mixing_bowl', NULL, '5-10 min', 'intermediate', 'Add oil in slow stream while whisking continuously to build emulsion.'),
  ('butter_temper_softened', 'no_heat', 'mixing_bowl', NULL, '65-70', '30-60 min', 'beginner', 'Butter at room temp before incorporation; do not melt.'),
  ('saute_aromatics', 'fat_based', 'saute_pan', NULL, '300-350', '5-10 min', 'beginner', 'Sweat onions, garlic, shallot until translucent; do not brown for pate.'),
  ('deglaze_flambe', 'combination', 'saute_pan', NULL, '350-400', '2-3 min', 'intermediate', 'Open-flame ignition of alcohol; pull pan from heat first to avoid flare-up.'),
  ('puree_smooth', 'no_heat', 'food_processor', NULL, NULL, '2-5 min', 'beginner', 'Process until silky smooth; pass through fine sieve for refined texture.'),
  ('terrine_water_bath_bake', 'combination', 'terrine_mold', 'water_bath_setup', '300', '60-90 min', 'intermediate', 'Internal temp 155F for safety; water bath ensures even gentle bake.'),
  ('chill_overnight', 'no_heat', 'mixing_bowl', NULL, '38-42', '8-12 hours', 'beginner', 'Allows flavors to meld and pate to firm up for slicing.'),
  ('salt_draw_moisture', 'no_heat', 'mixing_bowl', NULL, NULL, '15-30 min', 'beginner', 'Salt extracts moisture from vegetables before pickling, improves crunch.'),
  ('quick_pickle_brine_room_temp_4hr', 'no_heat', 'mixing_bowl', NULL, NULL, '4 hours', 'beginner', 'Shorter pickle preserves crunch; less sour.'),
  ('quick_pickle_brine_room_temp_24hr', 'no_heat', 'mixing_bowl', NULL, NULL, '24 hours', 'beginner', 'Longer pickle is more sour with less crunch.'),
  ('marinate_overnight_8hr_minimum', 'no_heat', 'mixing_bowl', NULL, '38-42', '8-24 hours', 'beginner', 'Refrigerated; flip or stir halfway through.'),
  ('grill_charcoal_high_heat', 'dry_heat', 'charcoal_grill', NULL, '600-800', '8-12 min', 'intermediate', 'High BTU contributes signature smoke and char.'),
  ('broil_high', 'dry_heat', 'broiler', NULL, '500-550', '8-12 min', 'beginner', 'Substitute for charcoal grilling; top rack closest to element.'),
  ('blend_smooth', 'no_heat', 'food_processor', NULL, NULL, '2-5 min', 'beginner', 'Pulse aromatics with liquid until uniformly chopped or smooth.'),
  ('marinate_apply_rest_30min_at_room_temp_then_chill', 'no_heat', 'mixing_bowl', NULL, NULL, '8-24 hours', 'beginner', 'Coat protein with marinade, rest 30 min ambient for absorption, then chill.')
) AS t(name, method_name, primary_eq_name, secondary_eq_name, temp, duration, difficulty, notes)
JOIN cooking_methods cm ON cm.name = t.method_name
JOIN equipment eq1 ON eq1.name = t.primary_eq_name
LEFT JOIN equipment eq2 ON eq2.name = t.secondary_eq_name;

-- ============================================================
-- INGREDIENT CATEGORIES (7 rows)
-- ============================================================

INSERT INTO ingredient_categories (id, name, parent_id, description, provenance) VALUES
  (gen_random_uuid(), 'proteins', NULL, 'Animal and plant proteins.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'vegetables', NULL, 'Fresh and prepared vegetables, herbs, aromatics.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'pantry', NULL, 'Dry pantry staples: flours, sugars, salts, dried spices, vinegars.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'dairy', NULL, 'Milk, butter, cheese, eggs (eggs cataloged here for kitchen-use grouping).', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'fats_and_oils', NULL, 'Cooking and finishing fats and oils.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'sauces_and_condiments', NULL, 'Bottled and prepared sauces, condiments, and umami liquids.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'beverages_and_alcohol', NULL, 'Cooking wines, spirits, beer used as recipe components.', 'llm_inferred_low_confidence');

-- ============================================================
-- CUISINES (1 row for v1)
-- ============================================================

INSERT INTO cuisines (id, name, parent_id, region_bias, description, provenance) VALUES
  (gen_random_uuid(), 'Vietnamese', NULL, 'Southeast Asia', 'Vietnamese cuisine, encompassing regional variants (Northern, Central, Southern).', 'llm_inferred_low_confidence');

-- ============================================================
-- INGREDIENTS (46 rows: 37 banh mi originals + 9 substitutes)
-- ============================================================

INSERT INTO ingredients (id, canonical_name, display_name, category_id, subcategory_id, default_unit, usda_commodity_code, description, provenance)
SELECT gen_random_uuid(), i.canonical_name, i.display_name, cat.id, NULL, i.default_unit, i.usda_code, i.description, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  -- Pantry (flours, sugars, salts, vinegars, etc)
  ('bread_flour_high_protein_unbleached', 'Bread flour, high-protein, unbleached', 'pantry', 'g', NULL::text, 'High-protein bread flour for chewy crumb structure.'),
  ('rice_flour_white', 'Rice flour, white', 'pantry', 'g', NULL, 'Fine white rice flour, used in small amounts for crackle in Vietnamese baguette.'),
  ('all_purpose_flour', 'All-purpose flour', 'pantry', 'g', NULL, 'Standard medium-protein flour, substitute for bread flour with reduced chew.'),
  ('sugar_white_granulated', 'Sugar, white granulated', 'pantry', 'g', NULL, 'Standard white granulated sugar.'),
  ('palm_sugar_grated', 'Palm sugar, grated', 'pantry', 'g', NULL, 'Vietnamese palm sugar with caramel notes; brown sugar acceptable substitute.'),
  ('caramel_sauce_nuoc_mau_vietnamese', 'Caramel sauce (nuoc mau)', 'pantry', 'ml', NULL, 'Vietnamese cooking caramel; bittersweet, used for color and depth.'),
  ('fine_sea_salt', 'Fine sea salt', 'pantry', 'g', NULL, 'Fine-grain sea salt for general seasoning.'),
  ('msg', 'MSG (monosodium glutamate)', 'pantry', 'g', NULL, 'Crystalline glutamate seasoning.'),
  ('rice_vinegar_unseasoned', 'Rice vinegar, unseasoned', 'pantry', 'ml', NULL, 'Plain rice vinegar without sugar or salt added.'),
  ('black_pepper_fresh_ground', 'Black pepper, fresh ground', 'pantry', 'g', NULL, 'Whole black peppercorns, ground at use.'),
  ('nutmeg_fresh_grated', 'Nutmeg, fresh-grated', 'pantry', 'g', NULL, 'Whole nutmeg, microplaned at use.'),
  ('instant_yeast', 'Instant yeast', 'pantry', 'g', NULL, 'Commercial instant dry yeast.'),
  ('ascorbic_acid_powder', 'Ascorbic acid powder', 'pantry', 'g', NULL, 'Vitamin C powder used as dough conditioner in commercial baguette.'),
  -- Vegetables
  ('daikon_radish_julienned', 'Daikon radish, julienned', 'vegetables', 'g', NULL, 'White Asian radish, cut into matchsticks for pickle.'),
  ('jicama_julienned', 'Jicama, julienned', 'vegetables', 'g', NULL, 'Mexican turnip-tuber, sweet-crunchy, substitute for daikon in pickle.'),
  ('carrot_julienned', 'Carrot, julienned', 'vegetables', 'g', NULL, 'Carrot cut into matchsticks for pickle.'),
  ('cilantro_fresh_sprigs', 'Cilantro, fresh sprigs', 'vegetables', 'g', NULL, 'Fresh cilantro leaves with tender stems.'),
  ('jalapeno_fresh_sliced_thin', 'Jalapeno, fresh, sliced thin', 'vegetables', 'g', NULL, 'Fresh jalapeno chile, thin slices.'),
  ('cucumber_english_thin_spears', 'Cucumber, English, thin spears', 'vegetables', 'g', NULL, 'English (seedless) cucumber cut into thin lengthwise spears.'),
  ('shallot_finely_diced', 'Shallot, finely diced', 'vegetables', 'g', NULL, 'Fresh shallot, fine dice for pate.'),
  ('shallot_finely_minced', 'Shallot, finely minced', 'vegetables', 'g', NULL, 'Fresh shallot, fine mince for marinade.'),
  ('garlic_minced', 'Garlic, minced', 'vegetables', 'g', NULL, 'Fresh garlic cloves, minced.'),
  ('lemongrass_white_parts_finely_minced', 'Lemongrass, white parts only, finely minced', 'vegetables', 'g', NULL, 'Tender white inner stalks of lemongrass, finely minced.'),
  ('ginger_fresh_grated', 'Ginger, fresh, grated', 'vegetables', 'g', NULL, 'Fresh ginger root, grated.'),
  ('mushroom_cremini_fresh', 'Mushroom, cremini, fresh', 'vegetables', 'g', NULL, 'Fresh cremini mushrooms; substitute for liver in vegan pate.'),
  -- Proteins
  ('pork_shoulder_boneless', 'Pork shoulder, boneless', 'proteins', 'g', NULL, 'Boneless pork shoulder, sliced 1/4-inch for grilling.'),
  ('pork_liver_fresh', 'Pork liver, fresh', 'proteins', 'g', NULL, 'Fresh pork liver, traditional pate base in Saigon banh mi.'),
  ('chicken_liver_fresh', 'Chicken liver, fresh', 'proteins', 'g', NULL, 'Fresh chicken liver, milder substitute for pork liver in pate.'),
  ('chicken_thigh_boneless_skinless', 'Chicken thigh, boneless, skinless', 'proteins', 'g', NULL, 'Boneless skinless chicken thigh, leaner protein substitute for pork shoulder.'),
  ('tofu_extra_firm_pressed', 'Tofu, extra-firm, pressed', 'proteins', 'g', NULL, 'Extra-firm tofu pressed to remove water, vegan protein substitute.'),
  ('pork_back_fat_or_fatty_pork_shoulder_chopped', 'Pork back fat or fatty pork shoulder, finely chopped', 'proteins', 'g', NULL, 'Fatty pork tissue for pate richness.'),
  ('egg_yolk_large_pasture_raised', 'Egg yolk, large, pasture-raised', 'dairy', 'each', NULL, 'Pasture-raised large egg yolk; deeper color and flavor than commercial.'),
  ('egg_yolk_large_commercial', 'Egg yolk, large, commercial', 'dairy', 'each', NULL, 'Standard commercial large egg yolk; cost-down substitute for pasture-raised.'),
  -- Fats and oils
  ('neutral_oil_canola_or_grapeseed', 'Neutral oil (canola or grapeseed)', 'fats_and_oils', 'ml', NULL, 'Neutral-flavored oil for emulsion or general cooking.'),
  ('avocado_oil', 'Avocado oil', 'fats_and_oils', 'ml', NULL, 'Premium high-heat oil with subtle buttery undertone.'),
  ('butter_unsalted_softened', 'Butter, unsalted, softened', 'dairy', 'g', NULL, 'Unsalted butter at room temperature for blending into mayo or pate.'),
  ('butter_unsalted', 'Butter, unsalted', 'dairy', 'g', NULL, 'Unsalted butter for cooking applications.'),
  -- Sauces and condiments
  ('fish_sauce_premium_red_boat_or_3_crabs', 'Fish sauce, premium (Red Boat 40N or 3 Crabs)', 'sauces_and_condiments', 'ml', NULL, 'Premium-grade Vietnamese fish sauce.'),
  ('fish_sauce_vegan_mushroom_seaweed', 'Fish sauce, vegan (mushroom-seaweed-soy)', 'sauces_and_condiments', 'ml', NULL, 'Plant-based fish sauce alternative made from fermented mushroom, seaweed, and soy.'),
  ('oyster_sauce', 'Oyster sauce', 'sauces_and_condiments', 'ml', NULL, 'Cantonese-style oyster sauce.'),
  ('hoisin_sauce', 'Hoisin sauce', 'sauces_and_condiments', 'ml', NULL, 'Sweet-savory fermented bean sauce.'),
  ('dark_soy_sauce', 'Dark soy sauce', 'sauces_and_condiments', 'ml', NULL, 'Aged dark soy sauce, primarily for color.'),
  ('maggi_seasoning_sauce', 'Maggi seasoning sauce', 'sauces_and_condiments', 'ml', NULL, 'Hydrolyzed-protein liquid umami booster.'),
  ('bragg_liquid_aminos', 'Bragg liquid aminos', 'sauces_and_condiments', 'ml', NULL, 'Soy-based liquid amino acid seasoning, lower-sodium soy alternative.'),
  -- Beverages and alcohol
  ('cognac_or_brandy', 'Cognac or brandy', 'beverages_and_alcohol', 'ml', NULL, 'French cognac or comparable brandy for pate flambe.'),
  -- Liquids
  ('water_room_temp', 'Water, room temperature', 'pantry', 'g', NULL, 'Water at room temperature for dough hydration.'),
  ('water', 'Water', 'pantry', 'ml', NULL, 'Water for general kitchen use.')
) AS i(canonical_name, display_name, category_name, default_unit, usda_code, description)
JOIN ingredient_categories cat ON cat.name = i.category_name;

-- ============================================================
-- INGREDIENT ALIASES (sample of common variants)
-- ============================================================

INSERT INTO ingredient_aliases (id, ingredient_id, alias_name, language, region_origin, notes, provenance)
SELECT gen_random_uuid(), ing.id, a.alias_name, a.language, a.region_origin, a.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('cilantro_fresh_sprigs', 'coriander leaves', 'en', 'UK and Commonwealth', 'British and Commonwealth English term for cilantro.'),
  ('cilantro_fresh_sprigs', 'Chinese parsley', 'en', 'older US usage', 'Older American produce-trade name for cilantro.'),
  ('cilantro_fresh_sprigs', 'dhaniya', 'hi', 'South Asia', 'Hindi/Urdu name for cilantro leaves.'),
  ('daikon_radish_julienned', 'mooli', 'hi', 'South Asia', 'South Asian term for daikon.'),
  ('daikon_radish_julienned', 'lo bak', 'zh', 'Chinese', 'Cantonese romanization for daikon.'),
  ('jalapeno_fresh_sliced_thin', 'jalapeño', 'es', 'Mexico', 'Spanish original spelling.'),
  ('lemongrass_white_parts_finely_minced', 'sa', 'vi', 'Vietnam', 'Vietnamese name for lemongrass.'),
  ('fish_sauce_premium_red_boat_or_3_crabs', 'nuoc mam', 'vi', 'Vietnam', 'Vietnamese name for fish sauce.'),
  ('fish_sauce_premium_red_boat_or_3_crabs', 'nam pla', 'th', 'Thailand', 'Thai name for fish sauce; Thai versions differ slightly in flavor profile.'),
  ('hoisin_sauce', 'hai xian jiang', 'zh', 'China', 'Mandarin Chinese name; literally "seafood sauce" though contains no seafood.'),
  ('msg', 'monosodium glutamate', 'en', 'global', 'Full chemical name.'),
  ('msg', 'aji-no-moto', 'ja', 'Japan', 'Japanese brand name commonly used as generic.')
) AS a(canonical_name, alias_name, language, region_origin, notes)
JOIN ingredients ing ON ing.canonical_name = a.canonical_name;

-- ============================================================
-- DISH (1 row: banh mi)
-- ============================================================

INSERT INTO dishes (id, name, cuisine_id, archetype_id, description, complexity_tier, provenance)
SELECT gen_random_uuid(), 'Banh mi (Saigon-style)', c.id, NULL, 'Vietnamese sandwich on a rice-flour-tinged baguette, traditionally with pate, butter mayo, grilled marinated pork, pickled daikon and carrot, fresh herbs, chili, and Maggi finish. Saigon (Southern) variant with cold cuts and pate is the export-standard form. Northern Vietnamese banh mi differs in fillings.', 'intermediate'::complexity_tier, 'llm_inferred_low_confidence'::provenance_type
FROM cuisines c WHERE c.name = 'Vietnamese';

-- ============================================================
-- RECIPES (7 rows: 1 parent + 5 sub-recipes + 1 nested marinade)
-- ============================================================

INSERT INTO recipes (id, dish_id, title, source, source_url, instructions, yield_quantity, yield_unit, complexity_tier, submitted_by_user_id, provenance, validity_window_end_date)
SELECT gen_random_uuid(), d.id, r.title, r.source, NULL, r.instructions, r.yield_qty, r.yield_unit, r.complexity::complexity_tier, NULL, 'llm_inferred_low_confidence'::provenance_type, r.validity_end::date
FROM (VALUES
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'Engine B v1 decomposition', 'Layer pate first on bottom half of split baguette. Spread butter mayo on top half. Lay pork over pate. Top with pickled daikon and carrot. Add cucumber spears, cilantro, jalapeno slices. Finish with several drops of Maggi sauce. Close sandwich.', 1, 'sandwich', 'intermediate', '2026-06-30'),
  ('Vietnamese baguette (rice-flour-tinged)', 'Engine B v1 decomposition', 'Bulk ferment dough at room temp 1-2 hours. Cold proof overnight. Shape into long loaves. Steam-injected bake at 460-475F for 18-22 minutes. Domestic substitute: bake at 475-500F with water pan on lower rack.', 1, 'loaf', 'intermediate', NULL),
  ('Vietnamese butter mayo (bo mayo)', 'Engine B v1 decomposition', 'Whisk egg yolk with rice vinegar, sugar, salt, MSG. Add neutral oil in slow stream while whisking until emulsified. Whisk in softened butter until fully incorporated. Refrigerate.', 230, 'g', 'intermediate', NULL),
  ('Pork liver pate (Vietnamese)', 'Engine B v1 decomposition', 'Saute shallot and garlic in butter until translucent. Add pork liver and pork fat, cook until just firmed. Deglaze with cognac and flambe. Cool slightly. Process with remaining butter, salt, pepper, nutmeg until smooth. Pack into terrine mold. Bake water bath at 300F for 60-90 min to internal 155F. Chill overnight before slicing.', 530, 'g', 'intermediate', NULL),
  ('Pickled daikon and carrot (do chua)', 'Engine B v1 decomposition', 'Salt julienned daikon and carrot, rest 15-30 min, drain. Combine rice vinegar, water, sugar, salt as brine. Pour over vegetables. Pickle at room temperature 4 hours (crunchier) or 24 hours (more sour).', 700, 'g', 'basic_prep', NULL),
  ('Lemongrass grilled pork (thit nuong)', 'Engine B v1 decomposition', 'Pre-salt sliced pork shoulder lightly. Coat with lemongrass marinade. Rest 30 min ambient then chill 8-24 hours. Grill over high charcoal heat 8-12 minutes total, turning once. Substitute: broil on top rack 8-12 min, turning once.', 500, 'g', 'intermediate', NULL),
  ('Lemongrass marinade (thit nuong base)', 'Engine B v1 decomposition', 'Combine lemongrass, garlic, shallot, ginger in food processor. Add fish sauce, oyster sauce, hoisin, palm sugar, caramel sauce, pepper, dark soy, oil. Blend smooth.', 200, 'ml', 'basic_prep', NULL)
) AS r(title, source, instructions, yield_qty, yield_unit, complexity, validity_end)
LEFT JOIN dishes d ON d.name = 'Banh mi (Saigon-style)' AND r.title LIKE 'Banh mi%';

-- ============================================================
-- RECIPE_INGREDIENTS (direct ingredients per recipe)
-- ============================================================

-- Banh mi parent recipe direct ingredients (cilantro, jalapeno, cucumber, Maggi)
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'cilantro_fresh_sprigs', 10::numeric, 'g', NULL::text, 'aromatic_finishing', NULL::text),
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'jalapeno_fresh_sliced_thin', 8, 'g', 'thin slices', 'heat_component', NULL),
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'cucumber_english_thin_spears', 30, 'g', 'thin lengthwise spears', 'vegetable_substance', NULL),
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'maggi_seasoning_sauce', 3, 'ml', 'few drops at finish', 'umami_base', 'Quintessential Vietnamese banh mi finish; do not skip.')
) AS ri(recipe_title, ingredient_canonical, qty, unit, prep, role_name, notes)
JOIN recipes r ON r.title = ri.recipe_title
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name;

-- Baguette sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('bread_flour_high_protein_unbleached', 350::numeric, 'g', NULL::text, 'dough_structure', false, NULL::text),
  ('rice_flour_white', 25, 'g', NULL, 'dough_structure', false, 'Gives signature crackle.'),
  ('water_room_temp', 230, 'g', NULL, 'cooking_liquid', false, 'Hydration.'),
  ('instant_yeast', 4, 'g', NULL, 'leavener', false, NULL),
  ('fine_sea_salt', 7, 'g', NULL, 'salt_seasoning', false, NULL),
  ('sugar_white_granulated', 6, 'g', NULL, 'sweetener', false, 'Yeast food and crust browning.'),
  ('ascorbic_acid_powder', 0.5, 'g', NULL, 'other_component', true, 'Dough conditioner improving rise and crumb structure.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Vietnamese baguette (rice-flour-tinged)';

-- Butter mayo sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('egg_yolk_large_pasture_raised', 1::numeric, 'each', NULL::text, 'emulsifier', false, 'Pasture-raised gives darker yolk and deeper flavor.'::text),
  ('neutral_oil_canola_or_grapeseed', 150, 'ml', NULL, 'structural_fat', false, NULL),
  ('butter_unsalted_softened', 50, 'g', 'softened to room temp', 'flavor_fat', false, 'Traditional bo mayo blends butter with oil for richness.'),
  ('rice_vinegar_unseasoned', 5, 'ml', NULL, 'acid', false, NULL),
  ('sugar_white_granulated', 4, 'g', NULL, 'sweetener', false, NULL),
  ('fine_sea_salt', 1.5, 'g', NULL, 'salt_seasoning', false, NULL),
  ('msg', 0.5, 'g', NULL, 'umami_base', true, 'Optional but traditional in kewpie-style.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Vietnamese butter mayo (bo mayo)';

-- Pate sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('pork_liver_fresh', 200::numeric, 'g', NULL::text, 'primary_protein', false, NULL::text),
  ('pork_back_fat_or_fatty_pork_shoulder_chopped', 100, 'g', 'finely chopped', 'flavor_fat', false, NULL),
  ('butter_unsalted', 50, 'g', NULL, 'flavor_fat', false, NULL),
  ('shallot_finely_diced', 80, 'g', NULL, 'aromatic_base', false, NULL),
  ('garlic_minced', 15, 'g', NULL, 'aromatic_base', false, NULL),
  ('cognac_or_brandy', 30, 'ml', NULL, 'flavor_liquid', false, NULL),
  ('black_pepper_fresh_ground', 2, 'g', NULL, 'spice_base', false, NULL),
  ('nutmeg_fresh_grated', 0.5, 'g', NULL, 'spice_accent', false, 'Common in Vietnamese pate, gentler than five-spice.'),
  ('fine_sea_salt', 4, 'g', NULL, 'salt_seasoning', false, NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Pork liver pate (Vietnamese)';

-- Pickled daikon and carrot sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('daikon_radish_julienned', 250::numeric, 'g', 'julienned'::text, 'vegetable_substance', NULL::text),
  ('carrot_julienned', 250, 'g', 'julienned', 'vegetable_substance', NULL),
  ('rice_vinegar_unseasoned', 240, 'ml', NULL, 'acid', NULL),
  ('water', 240, 'ml', NULL, 'cooking_liquid', 'Brine base.'),
  ('sugar_white_granulated', 100, 'g', NULL, 'sweetener', NULL),
  ('fine_sea_salt', 8, 'g', NULL, 'salt_seasoning', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Pickled daikon and carrot (do chua)';

-- Grilled pork sub-recipe direct ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('pork_shoulder_boneless', 500::numeric, 'g', 'sliced 1/4-inch thick'::text, 'primary_protein', NULL::text),
  ('fine_sea_salt', 4, 'g', NULL, 'salt_seasoning', 'Light pre-salt before marinade.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Lemongrass grilled pork (thit nuong)';

-- Lemongrass marinade sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('lemongrass_white_parts_finely_minced', 80::numeric, 'g', NULL::text, 'aromatic_base', NULL::text),
  ('garlic_minced', 30, 'g', NULL, 'aromatic_base', NULL),
  ('shallot_finely_minced', 40, 'g', NULL, 'aromatic_base', NULL),
  ('ginger_fresh_grated', 10, 'g', NULL, 'aromatic_base', NULL),
  ('fish_sauce_premium_red_boat_or_3_crabs', 60, 'ml', NULL, 'umami_base', NULL),
  ('oyster_sauce', 20, 'ml', NULL, 'umami_base', 'Glutamate depth and slight sweetness.'),
  ('hoisin_sauce', 15, 'ml', NULL, 'umami_base', 'Sweet-savory body and fermented bean flavor.'),
  ('palm_sugar_grated', 50, 'g', NULL, 'sweetener', 'Caramel notes; brown sugar acceptable substitute.'),
  ('caramel_sauce_nuoc_mau_vietnamese', 10, 'ml', NULL, 'sweetener', 'Bittersweet depth and color.'),
  ('black_pepper_fresh_ground', 3, 'g', NULL, 'spice_base', NULL),
  ('dark_soy_sauce', 15, 'ml', NULL, 'flavor_liquid', 'Primarily for color.'),
  ('neutral_oil_canola_or_grapeseed', 30, 'ml', NULL, 'fat_for_cooking', 'Helps marinade adhere.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Lemongrass marinade (thit nuong base)';

-- ============================================================
-- RECIPE_SUB_RECIPES (parent-child links between recipes)
-- ============================================================

-- Banh mi parent links to 5 sub-recipes
INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, link.qty, link.unit, link.step_order, false, link.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'Vietnamese baguette (rice-flour-tinged)', 'starch_base', 1::numeric, 'loaf', 1, '~120g per sandwich.'::text),
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'Pork liver pate (Vietnamese)', 'interstitial_layer', 25, 'g', 2, NULL),
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'Vietnamese butter mayo (bo mayo)', 'condiment_component', 30, 'g', 3, NULL),
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'Pickled daikon and carrot (do chua)', 'pickle_component', 50, 'g', 4, NULL),
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'Lemongrass grilled pork (thit nuong)', 'primary_protein', 80, 'g', 5, NULL)
) AS link(parent_title, child_title, role_name, qty, unit, step_order, notes)
JOIN recipes parent ON parent.title = link.parent_title
JOIN recipes child ON child.title = link.child_title
JOIN ingredient_roles role ON role.name = link.role_name;

-- Grilled pork sub-recipe links to its own marinade sub-recipe
INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, 200, 'ml', 1, false, 'Marinade applied to all pork before grilling.', 'llm_inferred_low_confidence'::provenance_type
FROM recipes parent
JOIN recipes child ON child.title = 'Lemongrass marinade (thit nuong base)'
JOIN ingredient_roles role ON role.name = 'flavor_liquid'
WHERE parent.title = 'Lemongrass grilled pork (thit nuong)';

-- ============================================================
-- RECIPE_TECHNIQUES (linking recipes to techniques)
-- ============================================================

INSERT INTO recipe_techniques (id, recipe_id, technique_id, step_order, notes, provenance)
SELECT gen_random_uuid(), r.id, t.id, rt.step_order, rt.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Banh mi (Saigon-style, Houston metro April 2026)', 'assembly_layered_sandwich', 1, NULL::text),
  ('Vietnamese baguette (rice-flour-tinged)', 'bulk_ferment_room_temp', 1, NULL),
  ('Vietnamese baguette (rice-flour-tinged)', 'cold_proof_overnight', 2, NULL),
  ('Vietnamese baguette (rice-flour-tinged)', 'steam_injected_bake', 3, 'Default; use domestic_steam_pan_bake as substitute if no commercial deck oven.'),
  ('Vietnamese butter mayo (bo mayo)', 'butter_temper_softened', 1, NULL),
  ('Vietnamese butter mayo (bo mayo)', 'cold_emulsion_whisked', 2, NULL),
  ('Pork liver pate (Vietnamese)', 'saute_aromatics', 1, NULL),
  ('Pork liver pate (Vietnamese)', 'deglaze_flambe', 2, NULL),
  ('Pork liver pate (Vietnamese)', 'puree_smooth', 3, NULL),
  ('Pork liver pate (Vietnamese)', 'terrine_water_bath_bake', 4, NULL),
  ('Pork liver pate (Vietnamese)', 'chill_overnight', 5, NULL),
  ('Pickled daikon and carrot (do chua)', 'salt_draw_moisture', 1, NULL),
  ('Pickled daikon and carrot (do chua)', 'quick_pickle_brine_room_temp_4hr', 2, 'Default; use _24hr variant for more sour, less crunch.'),
  ('Lemongrass grilled pork (thit nuong)', 'marinate_overnight_8hr_minimum', 1, NULL),
  ('Lemongrass grilled pork (thit nuong)', 'grill_charcoal_high_heat', 2, 'Default; use broil_high as substitute.'),
  ('Lemongrass marinade (thit nuong base)', 'blend_smooth', 1, NULL),
  ('Lemongrass marinade (thit nuong base)', 'marinate_apply_rest_30min_at_room_temp_then_chill', 2, NULL)
) AS rt(recipe_title, technique_name, step_order, notes)
JOIN recipes r ON r.title = rt.recipe_title
JOIN techniques t ON t.name = rt.technique_name;

-- ============================================================
-- SUBSTITUTIONS (11 rows with regional and seasonal weighting)
-- All substitute ingredients now exist in ingredients table.
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
  ('pork_shoulder_boneless', 'chicken_thigh_boneless_skinless', 'primary_protein', 'Vietnamese',
   'cost_reduction', 'ingredient_swap', 0.65::numeric, 'cheaper',
   NULL::text,
   'Reduce marinade time to 4 hours; chicken absorbs faster than pork.',
   'Lose: pork fat mouthfeel, traditional flavor, marinade depth. Gain: faster cook, lower cost. Compensate: increase fish sauce in marinade by 25%, add 1 tbsp neutral oil before grilling. When appropriate: cost-conscious operations, halal-adjacent menus. When NOT appropriate: when authentic Saigon banh mi is the menu claim.',
   'high', 'stable'),
  ('pork_shoulder_boneless', 'tofu_extra_firm_pressed', 'primary_protein', 'Vietnamese',
   'dietary_restriction', 'ingredient_swap', 0.45, 'cheaper', NULL,
   'Marinate 24h+ minimum; tofu absorbs slowly.',
   'Lose: meat richness, grill char from animal fat, traditional dish identity. Gain: vegan option. Compensate: add 1 tsp toasted sesame oil to marinade for missing fat-aromatic, finish with extra Maggi at service, char surface aggressively for missing meat-Maillard. When appropriate: explicit vegan menu position. When NOT appropriate: customers expecting traditional banh mi flavor.',
   'high', 'stable'),
  ('pork_liver_fresh', 'chicken_liver_fresh', 'primary_protein', 'Vietnamese',
   'availability_swap', 'ingredient_swap', 0.80, 'similar', NULL, NULL,
   'Lose: pork deeper iron-mineral flavor, slightly firmer texture. Gain: easier sourcing in some markets, milder profile. Compensate: add 10% pork fat back to chicken liver mix to match richness. When appropriate: when pork liver is hard to source. When NOT appropriate: in Houston specifically, pork liver is sourceable, this swap is unnecessary.',
   'low', 'stable'),
  ('pork_liver_fresh', 'mushroom_cremini_fresh', 'primary_protein', 'Vietnamese',
   'dietary_restriction', 'ingredient_swap', 0.50, 'similar', NULL,
   'Char half the mushrooms before blending for missing roasted-meat note.',
   'Lose: meat umami body, animal fat richness, iron-mineral note. Gain: vegan option, earthy umami via mushroom. Compensate: add 1 tsp soy sauce or miso, 2 tbsp olive oil for spreadable texture, 1/4 tsp smoked paprika for depth. When appropriate: vegan menu, fall-winter menus. When NOT appropriate: customers expecting traditional banh mi profile.',
   'high', 'stable'),
  ('bread_flour_high_protein_unbleached', 'all_purpose_flour', 'dough_structure', 'Vietnamese',
   'availability_swap', 'ingredient_swap', 0.55, 'similar', NULL,
   'Toast briefly to mimic crackle; avoid sourdough.',
   'Lose: rice-flour signature crackle, lighter Viet-style crumb, dish authenticity. Gain: universal availability. Compensate: minimal, the bread texture IS the dish identity. When appropriate: when no Vietnamese bakery is accessible. When NOT appropriate: in Houston, Vietnamese bakeries are abundant; this swap is unnecessary.',
   'low', 'stable'),
  ('daikon_radish_julienned', 'jicama_julienned', 'vegetable_substance', 'Vietnamese',
   'availability_swap', 'ingredient_swap', 0.70, 'similar', NULL,
   'Hold pickle to 4 hours max; jicama softens faster than daikon.',
   'Lose: peppery edge of daikon, slight authenticity. Gain: similar crunch, slightly sweeter. Compensate: reduce sugar in pickle by 20%. When appropriate: when daikon is hard to source. When NOT appropriate: in Houston, daikon is abundant; this swap is unnecessary.',
   'low', 'stable'),
  ('maggi_seasoning_sauce', 'bragg_liquid_aminos', 'umami_base', 'Vietnamese',
   'availability_swap', 'ingredient_swap', 0.60, 'similar', NULL, NULL,
   'Lose: Maggi specific hydrolyzed-protein character. Gain: easier sourcing. Compensate: ratio 5 parts liquid aminos to 1 drop Worcestershire. WARNING: do NOT substitute soy sauce alone, lacks meaty depth.',
   'low', 'stable'),
  ('fish_sauce_premium_red_boat_or_3_crabs', 'fish_sauce_vegan_mushroom_seaweed', 'umami_base', 'Vietnamese',
   'dietary_restriction', 'ingredient_swap', 0.65, 'more_expensive', NULL, NULL,
   'Lose: anchovy fermentation funk and depth. Gain: plant-based option. Compensate: use 25% more by volume to compensate for slightly weaker umami punch. WARNING: do NOT substitute soy sauce alone, lacks fermented-fish funk and would change dish character.',
   'medium', 'stable'),
  ('pork_shoulder_boneless', 'pork_shoulder_boneless', 'primary_protein', 'Vietnamese',
   'technique_simplification', 'technique_swap', 0.70, 'similar', 'broil_high',
   'Add 1 tsp smoked paprika to marinade for missing smoke; broil on top rack closest to element.',
   'Lose: charcoal smoke, direct radiant sear. Gain: home-kitchen feasibility, no charcoal infrastructure. When appropriate: indoor kitchens, urban food trucks without charcoal. When NOT appropriate: when smoky flavor is the menu position.',
   'medium', 'stable'),
  ('egg_yolk_large_pasture_raised', 'egg_yolk_large_commercial', 'emulsifier', 'Vietnamese',
   'cost_reduction', 'ingredient_swap', 0.75, 'cheaper', NULL, NULL,
   'Lose: deeper yolk color, richer mouthfeel, pronounced egg flavor. Gain: lower cost, easier sourcing. Compensate: add a few extra grains of MSG, brighten with slightly more rice vinegar. When appropriate: cost-tight operations. When NOT appropriate: high-end menu where egg quality is part of food story.',
   'high', 'stable'),
  ('neutral_oil_canola_or_grapeseed', 'avocado_oil', 'structural_fat', 'Vietnamese',
   'quality_improvement', 'ingredient_swap', 0.85, 'more_expensive', NULL, NULL,
   'Lose: cost-effectiveness. Gain: cleaner finish, slightly buttery undertone, premium positioning. Compensate: pricing must adjust. When appropriate: premium menu positioning, health-conscious menu. When NOT appropriate: cost-driven operations.',
   'medium', 'stable')
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

-- SELECT 'cooking_methods' AS t, COUNT(*) FROM cooking_methods
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
-- UNION ALL SELECT 'substitutions', COUNT(*) FROM substitutions;

-- Expected counts after this seed:
-- cooking_methods: 6
-- equipment: 13
-- techniques: 20
-- ingredient_categories: 7
-- cuisines: 1
-- ingredients: 46
-- ingredient_aliases: 12
-- dishes: 1
-- recipes: 7
-- recipe_ingredients: 47
-- recipe_sub_recipes: 6
-- recipe_techniques: 17
-- substitutions: 11
