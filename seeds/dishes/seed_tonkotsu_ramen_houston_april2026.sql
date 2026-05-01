-- ============================================================
-- Seed: Tonkotsu ramen (Hakata-style, Houston metro, April 2026)
-- Second real seed via Engine B output (iteration 3, score 9.0/10).
--
-- Provenance for ALL rows: llm_inferred_low_confidence
-- All rows await human review and promotion.
--
-- Run after: banh mi seed completed (cooking_methods already exist).
-- This seed adds equipment, techniques, ingredients, etc. that
-- did not exist in banh mi seed.
--
-- All inserts in a single transaction.
-- ============================================================

BEGIN;

-- ============================================================
-- EQUIPMENT (10 new rows)
-- ============================================================

INSERT INTO equipment (id, name, equipment_type, thermal_property_notes, max_practical_temp_f, description, provenance) VALUES
  (gen_random_uuid(), 'stock_pot_large', 'vessel', 'Heavy-duty large stock pot for long-duration boil.', 250, 'Stock pot 30L+ capacity for tonkotsu broth and large-batch braises.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'ladle', 'tool', NULL, NULL, 'Long-handled deep spoon for serving broth.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'ice_bath_setup', 'vessel', 'Ice and water mixture for rapid chilling.', 40, 'Mixing bowl with ice and water to halt cooking quickly.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'hand_torch', 'tool', 'Butane or propane handheld torch for surface searing.', 2400, 'Kitchen torch for finishing chashu and other surface treatments.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'pasta_machine_or_noodle_extruder', 'appliance', NULL, NULL, 'Manual or motorized pasta machine or dedicated noodle extruder.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'rolling_pin', 'tool', NULL, NULL, 'Wooden or marble rolling pin for dough.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'kitchen_twine', 'tool', 'Cotton butchers twine for trussing.', NULL, 'Cotton twine for tying meat rolls.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'fine_mesh_strainer', 'tool', NULL, NULL, 'Conical or flat fine-mesh strainer for clarifying liquids.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'egg_piercer', 'tool', NULL, NULL, 'Pin or needle device for piercing egg shell wide end before cooking.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'steamer_basket', 'vessel', 'Bamboo or metal basket suspended over boiling water.', 250, 'Steamer for gentle moist heat cooking.', 'llm_inferred_low_confidence');

-- ============================================================
-- TECHNIQUES (31 new rows)
-- ============================================================

INSERT INTO techniques (id, name, method_id, primary_equipment_id, secondary_equipment_id, temperature_range_f, duration_range, difficulty_tier, notes, provenance)
SELECT gen_random_uuid(), t.name, cm.id, eq1.id, eq2.id, t.temp, t.duration, t.difficulty::technique_difficulty, t.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('assembly_layered_bowl', 'no_heat', 'mixing_bowl', NULL::text, NULL::text, '5-10 min', 'beginner', 'Layer order: tare bottom, broth poured over, then noodles, then arranged toppings. Speed matters; assemble fast to keep hot.'),
  ('blanch_bones_pre_boil', 'moist_heat', 'stock_pot_large', NULL, '200-212', '5-10 min', 'beginner', 'Blanch bones, drain, rinse to remove blood and impurities before main boil.'),
  ('rolling_boil_emulsify_8hr_minimum_to_18hr', 'moist_heat', 'stock_pot_large', NULL, '212', '8-18 hours', 'intermediate', 'Maintain rolling boil. Do NOT skim. Long boil emulsifies fat and collagen into milky broth.'),
  ('skim_strain_clarify_to_emulsion', 'combination', 'fine_mesh_strainer', 'stock_pot_large', NULL, 'periodic', 'beginner', 'Strain at end through fine mesh to remove bone fragments while keeping emulsion intact.'),
  ('cold_soak_kombu_overnight', 'no_heat', 'mixing_bowl', NULL, '38-42', '8-12 hours', 'beginner', 'Cold extraction preserves delicate kombu umami; do not heat above 140F to avoid bitterness.'),
  ('gentle_simmer_dashi_extract', 'moist_heat', 'saute_pan', NULL, '140-150', '10 min', 'intermediate', 'Add katsuobushi, niboshi, shiitake to kombu cold-brew. Heat gently. Do NOT boil. Strain.'),
  ('strain_fine_mesh', 'no_heat', 'fine_mesh_strainer', NULL, NULL, '5 min', 'beginner', 'Pass through fine mesh for clarity.'),
  ('combine_simmer_reduce_tare', 'combination', 'saute_pan', NULL, '200', '10 min', 'intermediate', 'Combine soy, mirin, sake, dashi, sugar, salt. Simmer 10 min. Cool.'),
  ('age_24hr_minimum', 'no_heat', 'mixing_bowl', NULL, '38-42', '24+ hours', 'beginner', 'Cold-age tare for flavor development; refrigerate at minimum 24 hours before use.'),
  ('low_temp_garlic_confit_20min', 'fat_based', 'saute_pan', NULL, '250-275', '20 min', 'beginner', 'Cook garlic gently in oil until soft and translucent before blackening.'),
  ('high_heat_blacken_garlic_until_charred', 'dry_heat', 'saute_pan', NULL, '400-450', '2-3 min', 'intermediate', 'Increase heat; garlic blackens to char. Do NOT cross into bitter-burned. The flavor distinction is real.'),
  ('blend_smooth_with_oil', 'no_heat', 'food_processor', NULL, NULL, '2-5 min', 'beginner', 'Blend charred garlic with oil until smooth and uniformly black. Strain if desired.'),
  ('truss_pork_belly_roll', 'no_heat', 'kitchen_twine', NULL, NULL, '5 min', 'beginner', 'Roll skinless pork belly tightly, tie with twine at 1-inch intervals.'),
  ('sear_all_sides_dry_heat', 'dry_heat', 'saute_pan', NULL, '400', '5 min', 'beginner', 'Brown surface for Maillard before braise; develops flavor and color.'),
  ('braise_low_simmer_2hr', 'combination', 'stock_pot_large', NULL, '190', '2 hours', 'beginner', 'Internal temp ~190F for collagen breakdown. Gentle simmer, not rolling boil.'),
  ('chill_overnight_in_braising_liquid', 'no_heat', 'mixing_bowl', NULL, '38-42', '8-12 hours', 'beginner', 'Develops flavor and firms texture for clean slicing.'),
  ('slice_thin_torch_finish_at_service', 'no_heat', 'chef_knife', 'hand_torch', '1500', '30 sec per slice', 'intermediate', 'Slice 1/4 inch thin from chilled roll. Optional torch for caramelized finish at service.'),
  ('pierce_egg_wide_end_pre_cook', 'no_heat', 'egg_piercer', NULL, NULL, '30 sec per egg', 'beginner', 'Pierce wide end (where air pocket sits). Releases pressure. Dramatically improves peelability after cooking.'),
  ('precision_steam_6min30sec', 'moist_heat', 'steamer_basket', NULL, '212', '6:30', 'beginner', 'Default for soft-boiled eggs. More forgiving than boiling. Modern ramen-shop standard. Set white, runny center.'),
  ('precision_soft_boil_6min30sec', 'moist_heat', 'stock_pot_large', NULL, '212', '6:30', 'intermediate', 'Traditional alternative to steaming. Plunge eggs into rolling boiling water. Less forgiving timing.'),
  ('salt_vinegar_addition_to_egg_cooking_water', 'no_heat', 'mixing_bowl', NULL, NULL, '5 sec', 'beginner', 'Add 1 tbsp salt and 1 tsp vinegar to cooking water before eggs. Aids shell separation.'),
  ('ice_bath_immediate', 'no_heat', 'ice_bath_setup', NULL, '32-40', '5+ min', 'beginner', 'Plunge cooked eggs into ice bath. Stops cooking. Contracts white away from shell.'),
  ('peel_under_running_water_at_air_pocket', 'no_heat', 'mixing_bowl', NULL, NULL, '1-2 min per egg', 'beginner', 'Start peel at the pierced wide end. Peel under running water for shell-membrane separation.'),
  ('marinate_chilled_4_24hr', 'no_heat', 'mixing_bowl', NULL, '38-42', '4-24 hours', 'beginner', 'Longer marinade = more color stain on egg surface and more flavor penetration.'),
  ('knead_or_machine_extrude_dough', 'no_heat', 'pasta_machine_or_noodle_extruder', NULL, NULL, '10-15 min', 'intermediate', 'Dense low-hydration ramen dough requires forceful kneading or mechanical extrusion.'),
  ('rest_dough_chilled_2hr_minimum', 'no_heat', 'mixing_bowl', NULL, '38-42', '2+ hours', 'beginner', 'Rest hydrates dough fully and relaxes gluten.'),
  ('roll_thin_pass_repeatedly', 'no_heat', 'pasta_machine_or_noodle_extruder', 'rolling_pin', NULL, '15 min', 'intermediate', 'Pass through pasta machine progressively thinner; sheet should be very thin for Hakata-style noodles.'),
  ('cut_thin_straight_strands', 'no_heat', 'pasta_machine_or_noodle_extruder', NULL, NULL, '5 min', 'intermediate', '1.0 to 1.4 mm strands for authentic Hakata thin straight noodles.'),
  ('fresh_boil_60_seconds_to_just_done', 'moist_heat', 'stock_pot_large', NULL, '212', '60 sec', 'beginner', 'Brief cook for thin fresh ramen noodles. Dont overcook; ramen overcooks in seconds.'),
  ('rinse_bamboo_blanch_remove_canning_liquid', 'moist_heat', 'saute_pan', NULL, '212', '2 min', 'beginner', 'Rinse and blanch canned bamboo to remove tinny canning liquid before marinating.'),
  ('saute_in_sesame_oil_high_heat_2min', 'fat_based', 'saute_pan', NULL, '400', '2 min', 'beginner', 'High heat saute of bamboo in sesame oil to develop nutty depth before marinade.'),
  ('simmer_in_marinade_15min', 'moist_heat', 'saute_pan', NULL, '200', '15 min', 'beginner', 'Gentle simmer to absorb marinade flavors.'),
  ('chill_overnight_for_flavor', 'no_heat', 'mixing_bowl', NULL, '38-42', '8-12 hours', 'beginner', 'Cold rest develops flavor and texture.'),
  ('slice_thin_at_service', 'no_heat', 'chef_knife', NULL, NULL, '1 min per portion', 'beginner', 'Cold-slice pre-made narutomaki or other firm components at assembly.')
) AS t(name, method_name, primary_eq_name, secondary_eq_name, temp, duration, difficulty, notes)
JOIN cooking_methods cm ON cm.name = t.method_name
JOIN equipment eq1 ON eq1.name = t.primary_eq_name
LEFT JOIN equipment eq2 ON eq2.name = t.secondary_eq_name;

-- ============================================================
-- CUISINE (1 new row)
-- ============================================================

INSERT INTO cuisines (id, name, parent_id, region_bias, description, provenance) VALUES
  (gen_random_uuid(), 'Japanese', NULL, 'East Asia', 'Japanese cuisine, encompassing regional variants (Kyushu, Kanto, Kansai, etc.).', 'llm_inferred_low_confidence');

-- ============================================================
-- INGREDIENTS (~50 new rows; some overlap intentionally avoided)
-- ============================================================

INSERT INTO ingredients (id, canonical_name, display_name, category_id, subcategory_id, default_unit, usda_commodity_code, description, provenance)
SELECT gen_random_uuid(), i.canonical_name, i.display_name, cat.id, NULL, i.default_unit, NULL, i.description, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  -- Proteins (pork bones for broth, pork belly for chashu, fish cake, eggs)
  ('pork_femur_bones_split', 'Pork femur bones, split', 'proteins', 'g', 'Femur bones split lengthwise to expose marrow.'),
  ('pork_trotters_split', 'Pork trotters, split', 'proteins', 'g', 'Pig feet split for collagen extraction in broth.'),
  ('pork_back_fat', 'Pork back fat', 'proteins', 'g', 'Subcutaneous pork fat from back; used for broth richness.'),
  ('pork_shoulder_bones', 'Pork shoulder bones', 'proteins', 'g', 'Bones from pork shoulder; supplemental gelatin source.'),
  ('chicken_backs', 'Chicken backs', 'proteins', 'g', 'Bony chicken back portions; supplemental for broth or substitute primary.'),
  ('pork_belly_skinless', 'Pork belly, skinless', 'proteins', 'g', 'Skinless pork belly slab for chashu rolling.'),
  ('pork_shoulder_for_chashu', 'Pork shoulder, for chashu', 'proteins', 'g', 'Pork shoulder as cost-down substitute for chashu belly.'),
  ('chicken_thigh_for_chashu', 'Chicken thigh, for chashu (boneless skinless)', 'proteins', 'g', 'Chicken thigh as halal/dietary substitute for chashu pork belly.'),
  ('eggs_large_fresh', 'Eggs, large, fresh', 'dairy', 'each', 'Large fresh chicken eggs.'),
  ('eggs_large_aged_7_to_10_days', 'Eggs, large, aged 7 to 10 days', 'dairy', 'each', 'Eggs aged a week or more; peel cleaner than ultra-fresh eggs for soft-boiled use.'),
  ('narutomaki_kamaboko_fish_cake_pink_swirl', 'Narutomaki (kamaboko fish cake with pink swirl)', 'proteins', 'g', 'Pre-made surimi-based fish cake; white outside with characteristic pink spiral. Hakata tonkotsu traditional topping.'),
  -- Pantry (Japanese specialty plus shared)
  ('soy_sauce_koikuchi_dark', 'Soy sauce, koikuchi (dark)', 'sauces_and_condiments', 'ml', 'Standard Japanese all-purpose dark soy sauce.'),
  ('mirin', 'Mirin', 'sauces_and_condiments', 'ml', 'Sweet rice wine for cooking; contributes sweetness, sheen, umami balance.'),
  ('sake', 'Sake', 'beverages_and_alcohol', 'ml', 'Japanese rice wine for cooking; deglazes and adds depth.'),
  ('kombu_dried', 'Kombu, dried', 'pantry', 'g', 'Dried kelp; foundational umami base for dashi.'),
  ('katsuobushi_dried_bonito_flakes', 'Katsuobushi (dried bonito flakes)', 'pantry', 'g', 'Smoked, fermented, dried, shaved bonito tuna; primary umami source in dashi.'),
  ('niboshi_dried_sardines', 'Niboshi (dried sardines)', 'pantry', 'g', 'Small dried sardines; deeper, more aggressive umami than katsuobushi.'),
  ('dried_shiitake', 'Dried shiitake mushrooms', 'pantry', 'g', 'Dried shiitake; adds vegetable umami to dashi.'),
  ('sugar_brown', 'Sugar, brown', 'pantry', 'g', 'Brown sugar with molasses content for chashu and similar applications.'),
  ('sesame_oil_toasted', 'Sesame oil, toasted', 'fats_and_oils', 'ml', 'Toasted sesame oil; nutty, aromatic finishing oil.'),
  ('chili_oil_la_yu', 'Chili oil (la-yu)', 'sauces_and_condiments', 'ml', 'Sichuan or Japanese chili-infused oil for heat finish.'),
  ('chili_pepper_dried_crushed', 'Chili pepper, dried, crushed', 'pantry', 'g', 'Dried red chili pepper, crushed; common Asian-cuisine heat source.'),
  ('white_pepper_ground', 'White pepper, ground', 'pantry', 'g', 'Ground white pepper; common ramen finish.'),
  ('toasted_sesame_seeds_white', 'Toasted sesame seeds, white', 'pantry', 'g', 'Toasted white sesame seeds for finish texture.'),
  -- Vegetables (Japanese specialty plus shared)
  ('long_onion_white_parts', 'Long onion (negi), white parts', 'vegetables', 'g', 'Japanese long onion white sections; aromatic base.'),
  ('long_onion_green_parts', 'Long onion (negi), green parts', 'vegetables', 'g', 'Japanese long onion green sections; aromatic for braises.'),
  ('garlic_whole_crushed', 'Garlic, whole crushed', 'vegetables', 'g', 'Whole peeled garlic cloves crushed for broth aromatics.'),
  ('garlic_smashed', 'Garlic, smashed', 'vegetables', 'g', 'Smashed garlic for marinades and chashu braise.'),
  ('garlic_peeled_cloves', 'Garlic, peeled cloves', 'vegetables', 'g', 'Whole peeled garlic for confit applications like mayu.'),
  ('ginger_sliced', 'Ginger, sliced', 'vegetables', 'g', 'Fresh ginger sliced into rounds for braises and broths.'),
  ('green_onion_white_pale_green_smashed', 'Green onion, white and pale green parts, smashed', 'vegetables', 'g', 'Aromatic for ajitsuke tamago marinade.'),
  ('green_onion_thin_sliced', 'Green onion (scallion), thinly sliced', 'vegetables', 'g', 'Thin slices for finishing garnish on ramen.'),
  ('bamboo_shoots_canned_strips', 'Bamboo shoots, canned (sliced into long strips)', 'vegetables', 'g', 'Canned whole bamboo shoots cut into long strips for menma.'),
  ('wood_ear_mushroom_kikurage_rehydrated', 'Wood ear mushroom (kikurage), rehydrated, sliced thin', 'vegetables', 'g', 'Dried wood ear mushroom rehydrated and sliced; traditional Hakata tonkotsu garnish; earthy umami and crunchy texture.'),
  -- Sauces and condiments (more Japanese)
  ('beni_shoga_red_pickled_ginger', 'Beni shoga (red pickled ginger)', 'sauces_and_condiments', 'g', 'Pre-made red-pickled ginger strips; common Hakata tonkotsu topping.'),
  ('karashi_takana_japanese_pickled_mustard_greens', 'Karashi takana (Japanese spicy pickled mustard greens)', 'sauces_and_condiments', 'g', 'Pre-made spicy mustard greens; common Hakata tonkotsu topping.'),
  -- Pantry alkaline
  ('kansui_alkaline_solution', 'Kansui (alkaline mineral solution)', 'pantry', 'g', 'Potassium carbonate plus sodium carbonate solution. Gives ramen noodle yellow color, springy texture, characteristic smell. Required for authentic ramen noodles.'),
  -- Direct ingredient ramen noodles
  ('fresh_ramen_noodles_thin_straight_hakata_style', 'Fresh ramen noodles, thin straight, Hakata-style (Sun Noodle or equivalent)', 'pantry', 'g', 'Pre-made fresh kansui-treated ramen noodles, thin straight cut.'),
  ('dried_ramen_noodles_hakata_style', 'Dried ramen noodles, Hakata-style', 'pantry', 'g', 'Dried thin straight ramen noodles as substitute for fresh.'),
  -- Sea vegetables and finishing
  ('nori_sheet', 'Nori sheet (dried seaweed)', 'pantry', 'g', 'Dried seaweed sheet; contributes umami when broth-softened.'),
  -- Substitute ingredients for substitution rows (heavy cream warning, vegetarian)
  ('heavy_cream', 'Heavy cream', 'dairy', 'ml', 'Heavy whipping cream; sometimes used as broth shortcut, NOT traditional in tonkotsu.'),
  ('white_miso_paste', 'White miso paste', 'sauces_and_condiments', 'g', 'Light fermented soybean paste; vegetarian umami source.'),
  ('udon_noodles_fresh', 'Udon noodles, fresh', 'pantry', 'g', 'Thick wheat noodles; substitute for ramen when kansui unavailable but changes dish identity.')
) AS i(canonical_name, display_name, category_name, default_unit, description)
JOIN ingredient_categories cat ON cat.name = i.category_name;

-- ============================================================
-- INGREDIENT ALIASES (Japanese to English mappings)
-- ============================================================

INSERT INTO ingredient_aliases (id, ingredient_id, alias_name, language, region_origin, notes, provenance)
SELECT gen_random_uuid(), ing.id, a.alias_name, a.language, a.region_origin, a.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('katsuobushi_dried_bonito_flakes', 'bonito flakes', 'en', 'global', 'Common English name for katsuobushi.'),
  ('katsuobushi_dried_bonito_flakes', 'dried skipjack tuna flakes', 'en', 'global', 'Technical English description.'),
  ('niboshi_dried_sardines', 'iriko', 'ja', 'Japan', 'Alternate Japanese name for dried small sardines.'),
  ('niboshi_dried_sardines', 'dried baby anchovy', 'en', 'common usage', 'Often referred to in English as dried anchovies though technically sardines.'),
  ('kombu_dried', 'dashi kombu', 'ja', 'Japan', 'Specific kombu cultivar prized for dashi extraction.'),
  ('kombu_dried', 'dried kelp', 'en', 'global', 'English description.'),
  ('mirin', 'sweet rice wine', 'en', 'global', 'English description.'),
  ('sake', 'rice wine', 'en', 'global', 'English description.'),
  ('long_onion_white_parts', 'negi', 'ja', 'Japan', 'Japanese name for long onion.'),
  ('long_onion_white_parts', 'naga negi', 'ja', 'Japan', 'Specific cultivar designation.'),
  ('long_onion_white_parts', 'leek (substitute)', 'en', 'global', 'Often substituted by leek in Western kitchens though slightly different flavor.'),
  ('soy_sauce_koikuchi_dark', 'shoyu', 'ja', 'Japan', 'Japanese generic word for soy sauce.'),
  ('soy_sauce_koikuchi_dark', 'koikuchi shoyu', 'ja', 'Japan', 'Specific designation; the most common Japanese soy sauce.'),
  ('green_onion_thin_sliced', 'scallion', 'en', 'US', 'American English term.'),
  ('green_onion_thin_sliced', 'spring onion', 'en', 'UK', 'British English term.'),
  ('chili_oil_la_yu', 'rayu', 'ja', 'Japan', 'Japanese name; also written la-yu in romanization.'),
  ('chili_oil_la_yu', 'spicy chili oil', 'en', 'global', 'Generic English description.'),
  ('wood_ear_mushroom_kikurage_rehydrated', 'kikurage', 'ja', 'Japan', 'Japanese name.'),
  ('wood_ear_mushroom_kikurage_rehydrated', 'cloud ear fungus', 'en', 'global', 'Alternate English name.'),
  ('wood_ear_mushroom_kikurage_rehydrated', 'mu er', 'zh', 'China', 'Chinese name (Mandarin).'),
  ('narutomaki_kamaboko_fish_cake_pink_swirl', 'kamaboko', 'ja', 'Japan', 'Generic Japanese name for surimi fish cakes.'),
  ('narutomaki_kamaboko_fish_cake_pink_swirl', 'fish cake', 'en', 'global', 'Generic English description.'),
  ('beni_shoga_red_pickled_ginger', 'red pickled ginger', 'en', 'global', 'English description.'),
  ('karashi_takana_japanese_pickled_mustard_greens', 'spicy mustard greens', 'en', 'global', 'English description.'),
  ('bamboo_shoots_canned_strips', 'takenoko', 'ja', 'Japan', 'Japanese name for bamboo shoots.'),
  ('kansui_alkaline_solution', 'alkaline water', 'en', 'global', 'Functional English description.'),
  ('nori_sheet', 'dried seaweed sheet', 'en', 'global', 'English description.')
) AS a(canonical_name, alias_name, language, region_origin, notes)
JOIN ingredients ing ON ing.canonical_name = a.canonical_name;

-- ============================================================
-- DISH (1 new row)
-- ============================================================

INSERT INTO dishes (id, name, cuisine_id, archetype_id, description, complexity_tier, provenance)
SELECT gen_random_uuid(), 'Tonkotsu ramen (Hakata-style)', c.id, NULL,
  'Hakata-style tonkotsu ramen from Fukuoka prefecture in Kyushu. Characterized by emulsified milky pork bone broth, thin straight kansui noodles, and traditional toppings of chashu pork belly, marinated soft-boiled egg, narutomaki fish cake, scallion, nori, optional kikurage mushroom, beni shoga, and karashi takana. Default tare is shoyu; default aroma oil is mayu black garlic oil.',
  'advanced'::complexity_tier, 'llm_inferred_low_confidence'::provenance_type
FROM cuisines c WHERE c.name = 'Japanese';

-- ============================================================
-- RECIPES (8 rows: 1 parent + 7 sub-recipes)
-- ============================================================

INSERT INTO recipes (id, dish_id, title, source, source_url, instructions, yield_quantity, yield_unit, complexity_tier, submitted_by_user_id, provenance, validity_window_end_date)
SELECT gen_random_uuid(), d.id, r.title, r.source, NULL, r.instructions, r.yield_qty, r.yield_unit, r.complexity::complexity_tier, NULL, 'llm_inferred_low_confidence'::provenance_type, r.validity_end::date
FROM (VALUES
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'Engine B v1 decomposition', 'Bring tare into bowl (30 ml). Pour hot broth (400 ml) over tare. Add cooked thin ramen noodles. Arrange chashu slices, halved marinated egg, narutomaki rounds, sliced kikurage, menma. Top with scallion, nori sheet, sesame seeds. Drizzle mayu (5 ml). Optional beni shoga and karashi takana on side. Finish with white pepper if desired. Serve immediately.', 1, 'bowl', 'advanced', '2026-06-30'),
  ('Tonkotsu broth (pork bone broth)', 'Engine B v1 decomposition', 'Blanch all bones in boiling water 5-10 min. Drain and rinse. Place in stock pot with water and aromatics. Bring to rolling boil. Maintain rolling boil 8-18 hours, do NOT skim (emulsion is the goal). Top up water as needed. Strain through fine mesh at end.', 4500, 'ml', 'advanced', NULL),
  ('Shoyu tare (Hakata-style)', 'Engine B v1 decomposition', 'Cold-soak kombu in water overnight (8-12 hr). Heat gently to 140-150F. Add katsuobushi, niboshi, dried shiitake. Steep 10 min, do NOT boil. Strain. Combine with soy sauce, mirin, sake, sugar, salt. Simmer 10 min. Cool. Refrigerate 24+ hours before use.', 400, 'ml', 'intermediate', NULL),
  ('Mayu (black garlic oil)', 'Engine B v1 decomposition', 'Confit garlic cloves in mixed oils at 250-275F for 20 min until soft. Increase heat to 400-450F. Cook until garlic blackens (charred not bitter-burned), 2-3 min. Cool slightly. Blend smooth with oil in food processor. Strain if desired. Refrigerate.', 200, 'ml', 'intermediate', NULL),
  ('Chashu (rolled pork belly braised)', 'Engine B v1 decomposition', 'Roll pork belly tightly, tie with kitchen twine at 1-inch intervals. Sear all sides in saute pan over high heat. Transfer to stock pot with soy sauce, mirin, sake, sugar, garlic, ginger, long onion green, water. Braise gently at 190F internal for 2 hours. Cool in liquid. Refrigerate overnight. Slice 1/4 inch thin from cold roll. Optional torch finish at service.', 1000, 'g', 'intermediate', NULL),
  ('Ajitsuke tamago (marinated soft-boiled egg)', 'Engine B v1 decomposition', 'Use eggs aged 7-10 days for easier peeling. Pierce wide end with egg piercer. Add 1 tbsp salt and 1 tsp vinegar to steamer water. Steam eggs 6:30 over boiling water. Plunge into ice bath 5+ min. Peel under running water starting at pierced end. Combine soy sauce, mirin, sake, sugar, water, dashi, smashed green onion, sliced ginger, smashed garlic, optional chili oil for marinade. Submerge peeled eggs. Marinate chilled 4-24 hours.', 6, 'each', 'intermediate', NULL),
  ('Menma (quick-marinated bamboo shoots)', 'Engine B v1 decomposition', 'Rinse and blanch canned bamboo strips 2 min, drain. Saute in toasted sesame oil over high heat 2 min. Add soy sauce, mirin, sake, sugar, optional chili pepper, water. Simmer 15 min. Chill overnight in marinade.', 200, 'g', 'basic_prep', NULL),
  ('Kansui ramen noodles (from-scratch variant)', 'Engine B v1 decomposition', 'Combine flour, water, kansui, salt. Knead or machine-extrude until uniform; dough is dense and low-hydration. Rest chilled 2+ hours. Roll progressively thinner through pasta machine. Cut into 1.0-1.4 mm thin straight strands. Boil 60 seconds in salted water at service.', 700, 'g', 'advanced', NULL)
) AS r(title, source, instructions, yield_qty, yield_unit, complexity, validity_end)
LEFT JOIN dishes d ON d.name = 'Tonkotsu ramen (Hakata-style)' AND r.title LIKE 'Tonkotsu ramen%';

-- ============================================================
-- RECIPE_INGREDIENTS (direct ingredients per recipe)
-- ============================================================

-- Parent tonkotsu ramen recipe direct ingredients (assembled at service)
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('green_onion_thin_sliced', 8::numeric, 'g', 'thinly sliced'::text, 'aromatic_finishing', false, NULL::text),
  ('nori_sheet', 1, 'g', 'half sheet', 'umami_base', false, 'Also contributes textural element when broth-softened.'),
  ('toasted_sesame_seeds_white', 2, 'g', NULL, 'texture_crunch', true, 'Optional but traditional finishing.'),
  ('beni_shoga_red_pickled_ginger', 5, 'g', NULL, 'pickle_component', true, 'Traditional Hakata-style topping.'),
  ('karashi_takana_japanese_pickled_mustard_greens', 5, 'g', NULL, 'pickle_component', true, 'Traditional Hakata-style topping.'),
  ('white_pepper_ground', 0.3, 'g', 'pinch', 'spice_accent', true, 'Optional finish for heat and aroma.'),
  ('narutomaki_kamaboko_fish_cake_pink_swirl', 10, 'g', '2 thin slices', 'secondary_protein', false, 'Traditional Hakata fish cake topping.'),
  ('wood_ear_mushroom_kikurage_rehydrated', 5, 'g', 'rehydrated and sliced thin', 'vegetable_substance', true, 'Optional but traditional Hakata garnish; earthy umami and crunch.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Tonkotsu ramen (Hakata-style, Houston metro April 2026)';

-- Tonkotsu broth ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('pork_femur_bones_split', 1500::numeric, 'g', 'split lengthwise'::text, 'primary_protein', 'Marrow exposure essential for emulsion.'::text),
  ('pork_trotters_split', 800, 'g', 'split', 'primary_protein', 'Collagen source for emulsified body.'),
  ('pork_back_fat', 200, 'g', NULL, 'flavor_fat', 'Mouthfeel and richness.'),
  ('pork_shoulder_bones', 500, 'g', NULL, 'secondary_protein', 'Supplemental gelatin.'),
  ('garlic_whole_crushed', 50, 'g', 'whole crushed', 'aromatic_base', NULL),
  ('ginger_sliced', 30, 'g', 'sliced', 'aromatic_base', NULL),
  ('long_onion_white_parts', 100, 'g', NULL, 'aromatic_base', NULL),
  ('water', 6000, 'ml', NULL, 'cooking_liquid', 'Large volume for long boil.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Tonkotsu broth (pork bone broth)';

-- Shoyu tare ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('soy_sauce_koikuchi_dark', 200::numeric, 'ml', NULL::text, 'umami_base', NULL::text),
  ('mirin', 50, 'ml', NULL, 'sweetener', 'Also contributes flavor_liquid character.'),
  ('sake', 50, 'ml', NULL, 'flavor_liquid', NULL),
  ('kombu_dried', 15, 'g', NULL, 'umami_base', NULL),
  ('katsuobushi_dried_bonito_flakes', 15, 'g', NULL, 'umami_base', NULL),
  ('niboshi_dried_sardines', 8, 'g', NULL, 'umami_base', NULL),
  ('dried_shiitake', 5, 'g', NULL, 'umami_base', NULL),
  ('sugar_white_granulated', 8, 'g', NULL, 'sweetener', NULL),
  ('fine_sea_salt', 4, 'g', NULL, 'salt_seasoning', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Shoyu tare (Hakata-style)';

-- Mayu ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('garlic_peeled_cloves', 100::numeric, 'g', 'peeled whole'::text, 'aromatic_base', NULL::text),
  ('sesame_oil_toasted', 60, 'ml', NULL, 'flavor_fat', '30% of blend.'),
  ('neutral_oil_canola_or_grapeseed', 140, 'ml', NULL, 'fat_for_cooking', '70% of blend.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Mayu (black garlic oil)';

-- Chashu ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('pork_belly_skinless', 1000::numeric, 'g', 'rolled and tied with twine'::text, 'primary_protein', NULL::text),
  ('soy_sauce_koikuchi_dark', 250, 'ml', NULL, 'umami_base', NULL),
  ('mirin', 100, 'ml', NULL, 'sweetener', NULL),
  ('sake', 100, 'ml', NULL, 'flavor_liquid', NULL),
  ('sugar_brown', 50, 'g', NULL, 'sweetener', NULL),
  ('garlic_smashed', 30, 'g', 'smashed', 'aromatic_base', NULL),
  ('ginger_sliced', 20, 'g', 'sliced', 'aromatic_base', NULL),
  ('long_onion_green_parts', 50, 'g', NULL, 'aromatic_base', NULL),
  ('water', 800, 'ml', NULL, 'cooking_liquid', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Chashu (rolled pork belly braised)';

-- Ajitsuke tamago ingredients (revised with new aromatics)
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('eggs_large_aged_7_to_10_days', 6::numeric, 'each', 'pierced wide end'::text, 'primary_protein', false, 'Aged eggs peel cleaner than ultra-fresh.'::text),
  ('soy_sauce_koikuchi_dark', 100, 'ml', NULL, 'umami_base', false, NULL),
  ('mirin', 50, 'ml', NULL, 'sweetener', false, NULL),
  ('sake', 25, 'ml', NULL, 'flavor_liquid', false, NULL),
  ('sugar_white_granulated', 15, 'g', NULL, 'sweetener', false, NULL),
  ('water', 100, 'ml', NULL, 'cooking_liquid', false, NULL),
  ('green_onion_white_pale_green_smashed', 20, 'g', 'white and pale green smashed', 'aromatic_base', false, 'Traditional Hakata-style addition for depth.'),
  ('ginger_sliced', 8, 'g', 'sliced', 'aromatic_base', false, 'Traditional addition.'),
  ('garlic_smashed', 10, 'g', 'smashed', 'aromatic_base', false, 'Traditional addition.'),
  ('chili_oil_la_yu', 5, 'ml', NULL, 'heat_component', true, 'Optional regional variant for heat.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Ajitsuke tamago (marinated soft-boiled egg)';

-- Menma ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('bamboo_shoots_canned_strips', 200::numeric, 'g', 'strips'::text, 'vegetable_substance', false, NULL::text),
  ('sesame_oil_toasted', 10, 'ml', NULL, 'flavor_fat', false, NULL),
  ('soy_sauce_koikuchi_dark', 30, 'ml', NULL, 'umami_base', false, NULL),
  ('mirin', 15, 'ml', NULL, 'sweetener', false, NULL),
  ('sake', 15, 'ml', NULL, 'flavor_liquid', false, NULL),
  ('sugar_white_granulated', 5, 'g', NULL, 'sweetener', false, NULL),
  ('chili_pepper_dried_crushed', 1, 'g', 'crushed', 'heat_component', true, 'Optional.'),
  ('water', 100, 'ml', NULL, 'cooking_liquid', false, NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Menma (quick-marinated bamboo shoots)';

-- Kansui ramen noodles from-scratch ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('bread_flour_high_protein_unbleached', 500::numeric, 'g', NULL::text, 'dough_structure', NULL::text),
  ('water', 200, 'ml', 'cold', 'cooking_liquid', NULL),
  ('kansui_alkaline_solution', 5, 'g', NULL, 'other_component', 'Alkaline mineral solution; gives ramen yellow color, springy texture, characteristic smell. NO substitute possible without changing dish identity.'),
  ('fine_sea_salt', 5, 'g', NULL, 'salt_seasoning', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Kansui ramen noodles (from-scratch variant)';

-- Default noodle row on parent (uses pre-made)
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, 130, 'g', 'cooked 60 sec', role.id, false,
       'Default for v1: pre-made fresh ramen noodles (Sun Noodle or equivalent). From-scratch variant available as separate recipe.',
       'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM recipes r
JOIN ingredients ing ON ing.canonical_name = 'fresh_ramen_noodles_thin_straight_hakata_style'
JOIN ingredient_roles role ON role.name = 'starch_base'
WHERE r.title = 'Tonkotsu ramen (Hakata-style, Houston metro April 2026)';

-- ============================================================
-- RECIPE_SUB_RECIPES (parent-child links)
-- ============================================================

INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, link.qty, link.unit, link.step_order, false, link.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'Tonkotsu broth (pork bone broth)', 'sauce_body', 400::numeric, 'ml', 5, 'Multi-role: sauce_body primary, also functions as cooking_liquid in bowl.'::text),
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'Shoyu tare (Hakata-style)', 'flavor_paste', 30, 'ml', 1, 'Added to bowl first; broth poured over to mix.'),
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'Mayu (black garlic oil)', 'flavor_fat', 5, 'ml', 6, 'Drizzled at finish.'),
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'Chashu (rolled pork belly braised)', 'primary_protein', 60, 'g', 4, '3-4 thin slices.'),
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'Ajitsuke tamago (marinated soft-boiled egg)', 'secondary_protein', 30, 'g', 7, 'Half egg per bowl.'),
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'Menma (quick-marinated bamboo shoots)', 'pickle_component', 20, 'g', 8, NULL)
) AS link(parent_title, child_title, role_name, qty, unit, step_order, notes)
JOIN recipes parent ON parent.title = link.parent_title
JOIN recipes child ON child.title = link.child_title
JOIN ingredient_roles role ON role.name = link.role_name;

-- ============================================================
-- RECIPE_TECHNIQUES (linking recipes to techniques)
-- ============================================================

INSERT INTO recipe_techniques (id, recipe_id, technique_id, step_order, notes, provenance)
SELECT gen_random_uuid(), r.id, t.id, rt.step_order, rt.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'assembly_layered_bowl', 1, NULL::text),
  ('Tonkotsu broth (pork bone broth)', 'blanch_bones_pre_boil', 1, NULL),
  ('Tonkotsu broth (pork bone broth)', 'rolling_boil_emulsify_8hr_minimum_to_18hr', 2, 'Do NOT skim; emulsion is goal.'),
  ('Tonkotsu broth (pork bone broth)', 'skim_strain_clarify_to_emulsion', 3, 'Strain at end only.'),
  ('Shoyu tare (Hakata-style)', 'cold_soak_kombu_overnight', 1, NULL),
  ('Shoyu tare (Hakata-style)', 'gentle_simmer_dashi_extract', 2, NULL),
  ('Shoyu tare (Hakata-style)', 'strain_fine_mesh', 3, NULL),
  ('Shoyu tare (Hakata-style)', 'combine_simmer_reduce_tare', 4, NULL),
  ('Shoyu tare (Hakata-style)', 'age_24hr_minimum', 5, NULL),
  ('Mayu (black garlic oil)', 'low_temp_garlic_confit_20min', 1, NULL),
  ('Mayu (black garlic oil)', 'high_heat_blacken_garlic_until_charred', 2, 'Charred not bitter-burned.'),
  ('Mayu (black garlic oil)', 'blend_smooth_with_oil', 3, NULL),
  ('Chashu (rolled pork belly braised)', 'truss_pork_belly_roll', 1, NULL),
  ('Chashu (rolled pork belly braised)', 'sear_all_sides_dry_heat', 2, NULL),
  ('Chashu (rolled pork belly braised)', 'braise_low_simmer_2hr', 3, NULL),
  ('Chashu (rolled pork belly braised)', 'chill_overnight_in_braising_liquid', 4, NULL),
  ('Chashu (rolled pork belly braised)', 'slice_thin_torch_finish_at_service', 5, NULL),
  ('Ajitsuke tamago (marinated soft-boiled egg)', 'pierce_egg_wide_end_pre_cook', 1, 'Improves peelability dramatically.'),
  ('Ajitsuke tamago (marinated soft-boiled egg)', 'salt_vinegar_addition_to_egg_cooking_water', 2, NULL),
  ('Ajitsuke tamago (marinated soft-boiled egg)', 'precision_steam_6min30sec', 3, 'Default; steaming is more forgiving than boiling.'),
  ('Ajitsuke tamago (marinated soft-boiled egg)', 'ice_bath_immediate', 4, NULL),
  ('Ajitsuke tamago (marinated soft-boiled egg)', 'peel_under_running_water_at_air_pocket', 5, 'Start at pierced wide end.'),
  ('Ajitsuke tamago (marinated soft-boiled egg)', 'marinate_chilled_4_24hr', 6, NULL),
  ('Menma (quick-marinated bamboo shoots)', 'rinse_bamboo_blanch_remove_canning_liquid', 1, NULL),
  ('Menma (quick-marinated bamboo shoots)', 'saute_in_sesame_oil_high_heat_2min', 2, NULL),
  ('Menma (quick-marinated bamboo shoots)', 'simmer_in_marinade_15min', 3, NULL),
  ('Menma (quick-marinated bamboo shoots)', 'chill_overnight_for_flavor', 4, NULL),
  ('Kansui ramen noodles (from-scratch variant)', 'knead_or_machine_extrude_dough', 1, NULL),
  ('Kansui ramen noodles (from-scratch variant)', 'rest_dough_chilled_2hr_minimum', 2, NULL),
  ('Kansui ramen noodles (from-scratch variant)', 'roll_thin_pass_repeatedly', 3, NULL),
  ('Kansui ramen noodles (from-scratch variant)', 'cut_thin_straight_strands', 4, NULL),
  ('Kansui ramen noodles (from-scratch variant)', 'fresh_boil_60_seconds_to_just_done', 5, NULL),
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'fresh_boil_60_seconds_to_just_done', 3, 'Cook noodles in salted water briefly; thin Hakata noodles overcook in seconds.'),
  ('Tonkotsu ramen (Hakata-style, Houston metro April 2026)', 'slice_thin_at_service', 9, 'Slice narutomaki at service.')
) AS rt(recipe_title, technique_name, step_order, notes)
JOIN recipes r ON r.title = rt.recipe_title
JOIN techniques t ON t.name = rt.technique_name;

-- ============================================================
-- SUBSTITUTIONS (13 rows with regional and seasonal weighting)
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
  ('pork_femur_bones_split', 'pork_shoulder_bones', 'primary_protein', 'Japanese',
   'cost_reduction', 'ingredient_swap', 0.55::numeric, 'cheaper', NULL::text,
   'Extend boil to 18+ hours, add 200g chicken feet for collagen.',
   'Lose: signature milky emulsion (femur marrow + trotter collagen are essential), authentic mouthfeel. Gain: lower cost, easier sourcing. When appropriate: cost-tight operations. When NOT appropriate: when "tonkotsu" is the menu claim; without trotters/femur, it is not really tonkotsu.',
   'high', 'stable'),
  ('pork_femur_bones_split', 'chicken_backs', 'primary_protein', 'Japanese',
   'dietary_restriction', 'ingredient_swap', 0.45, 'similar', NULL,
   'This becomes paitan ramen, not tonkotsu. Rebrand the menu item.',
   'Lose: pork signature richness, authentic dish identity. Gain: halal compatibility, broader dietary appeal. When appropriate: halal menu position, never call it tonkotsu. When NOT appropriate: when serving authentic tonkotsu.',
   'high', 'stable'),
  ('soy_sauce_koikuchi_dark', 'fine_sea_salt', 'umami_base', 'Japanese',
   'cuisine_translation', 'ingredient_swap', 0.75, 'similar', NULL,
   'Increase niboshi by 20% in tare for missing umami punch from soy.',
   'Lose: soy color and umami depth. Gain: lighter cleaner flavor, lets pork broth shine. This is the shio tare variant. When appropriate: when wanting to highlight broth quality. When NOT appropriate: when shoyu is the explicit menu claim.',
   'medium', 'stable'),
  ('niboshi_dried_sardines', 'katsuobushi_dried_bonito_flakes', 'umami_base', 'Japanese',
   'availability_swap', 'ingredient_swap', 0.70, 'similar', NULL,
   'Increase katsuobushi by 50%, optionally add 1 small dried anchovy.',
   'Lose: niboshi specific fishy depth (oily, slightly bitter). Gain: cleaner umami if niboshi unavailable. When appropriate: when niboshi cannot be sourced. When NOT appropriate: when authenticity is high priority.',
   'medium', 'stable'),
  ('pork_belly_skinless', 'pork_shoulder_for_chashu', 'primary_protein', 'Japanese',
   'cost_reduction', 'ingredient_swap', 0.60, 'cheaper', NULL,
   'Braise longer (3+ hours), add 100g pork fat to braising liquid for missing richness.',
   'Lose: belly fat-to-meat ratio, melting texture. Gain: lower cost per gram. When appropriate: cost-conscious operations. When NOT appropriate: when chashu is the dish selling point.',
   'high', 'stable'),
  ('pork_belly_skinless', 'chicken_thigh_for_chashu', 'primary_protein', 'Japanese',
   'dietary_restriction', 'ingredient_swap', 0.50, 'cheaper', NULL,
   'Roll thigh tight, brine 4hr first, baste with chicken fat during braise. Rebrand as chicken chashu.',
   'Lose: pork belly signature fat melt, authentic flavor. Gain: halal option, lower cost. When appropriate: halal menu, lighter menu position. When NOT appropriate: traditional tonkotsu menu.',
   'high', 'stable'),
  ('fresh_ramen_noodles_thin_straight_hakata_style', 'dried_ramen_noodles_hakata_style', 'starch_base', 'Japanese',
   'technique_simplification', 'ingredient_swap', 0.70, 'similar', NULL,
   'Do NOT overcook dried; ramen noodles overcook in seconds. Cook 1 minute less than package says.',
   'Lose: fresh noodle springiness, ideal mouthfeel for thin Hakata style. Gain: shelf life, easier inventory. When appropriate: low-volume operations where fresh noodles spoil. When NOT appropriate: high-volume ramen-focused operations.',
   'medium', 'stable'),
  ('fresh_ramen_noodles_thin_straight_hakata_style', 'udon_noodles_fresh', 'starch_base', 'Japanese',
   'availability_swap', 'ingredient_swap', 0.40, 'similar', NULL,
   'Rebrand as tonkotsu udon, not ramen.',
   'Lose: ramen identity entirely; this is now a different dish. Gain: kansui-free option. When appropriate: when kansui truly unavailable, or when udon is preferred. When NOT appropriate: regular ramen menu position. Do NOT substitute regular wheat pasta for ramen; chemistry is wrong.',
   'low', 'stable'),
  ('pork_back_fat', 'heavy_cream', 'flavor_fat', 'Japanese',
   'technique_simplification', 'ingredient_swap', 0.30, 'similar', NULL,
   'WARNING: this is a fundamental departure from authentic technique.',
   'Lose: authenticity (cream is NOT traditional in tonkotsu). Gain: faster route to creamy mouthfeel, shorter boil time. When appropriate: never for serious ramen operations. Some fusion American ramen shops use this; flag clearly. When NOT appropriate: any ramen operation claiming traditional preparation. The texture comes from emulsified collagen and fat from real bone boil, not from cream.',
   'low', 'stable'),
  ('niboshi_dried_sardines', 'dried_shiitake', 'umami_base', 'Japanese',
   'dietary_restriction', 'ingredient_swap', 0.50, 'similar', NULL,
   'Increase shiitake by 100%, add 1 tsp soy sauce for missing fishiness.',
   'Lose: deep-sea umami complexity from niboshi/katsuobushi. Gain: vegetarian option for tare base. When appropriate: vegetarian ramen menu. When NOT appropriate: tonkotsu specifically (broth base is pork, not vegetarian compatible by definition).',
   'medium', 'stable'),
  ('eggs_large_aged_7_to_10_days', 'eggs_large_fresh', 'primary_protein', 'Japanese',
   'cost_reduction', 'ingredient_swap', 0.65, 'similar', NULL,
   'Plan for messier peeling. Use egg piercer aggressively.',
   'Lose: easier peeling. Gain: fresher flavor (marginal). When appropriate: when only fresh eggs are available. When NOT appropriate: when batch-cooking ajitsuke tamago at scale; aged eggs save labor.',
   'low', 'stable'),
  ('narutomaki_kamaboko_fish_cake_pink_swirl', 'pork_belly_skinless', 'secondary_protein', 'Japanese',
   'cost_reduction', 'ingredient_swap', 0.40, 'cheaper', NULL,
   'Skip narutomaki; emphasize chashu visually with extra slices.',
   'Lose: traditional Hakata visual element, slight textural variety. Gain: zero cost of fish cake. When appropriate: cost-tight operations, when fish cake hard to source. When NOT appropriate: when authentic Hakata presentation is the menu position.',
   'medium', 'stable'),
  ('eggs_large_fresh', 'eggs_large_fresh', 'primary_protein', 'Japanese',
   'technique_simplification', 'technique_swap', 0.95, 'similar', 'precision_steam_6min30sec',
   'Steaming is more forgiving than boiling. Same internal time. Easier peeling, more consistent set white.',
   'Lose: nothing meaningful; arguably gaining quality. Gain: more forgiving timing, easier peeling. When appropriate: most operations. When NOT appropriate: never; this is widely the better technique. Listed for completeness; engine recommends as default.',
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

-- Run this to confirm tonkotsu seed counts match expectations:
--
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
-- UNION ALL SELECT 'substitutions', COUNT(*) FROM substitutions
-- ORDER BY t;
--
-- Expected counts AFTER tonkotsu seed (cumulative with banh mi):
-- cooking_methods: 6 (no new)
-- equipment: 23 (13 banh mi + 10 tonkotsu)
-- techniques: 51 (20 banh mi + 31 tonkotsu)
-- ingredient_categories: 7 (no new)
-- cuisines: 2 (Vietnamese + Japanese)
-- ingredients: 90 (47 banh mi + 43 tonkotsu)
-- ingredient_aliases: 39 (12 banh mi + 27 tonkotsu)
-- dishes: 2 (banh mi + tonkotsu)
-- recipes: 15 (7 banh mi + 8 tonkotsu)
-- recipe_ingredients: 109 (47 banh mi + 62 tonkotsu)
-- recipe_sub_recipes: 12 (6 banh mi + 6 tonkotsu)
-- recipe_techniques: 51 (17 banh mi + 34 tonkotsu)
-- substitutions: 24 (11 banh mi + 13 tonkotsu)
