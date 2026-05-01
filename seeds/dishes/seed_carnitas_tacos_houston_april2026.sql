-- ============================================================
-- Seed: Carnitas tacos (Michoacán-style, Houston metro, April 2026)
-- Fifth real seed via Engine B v1.1 (iteration 3, score 9.0).
--
-- ALL ENUMS VERIFIED before writing:
--   complexity_tier: reheat_and_serve, basic_prep, intermediate, advanced, fine_dining
--   technique_difficulty: beginner, intermediate, advanced
--   cost_direction: cheaper, similar, more_expensive, variable
--   substitution_purpose: cost_reduction, quality_improvement, availability_swap,
--                         dietary_restriction, technique_simplification, cuisine_translation
--   substitution_kind: ingredient_swap, technique_swap, combined
--   inference_source: human_entered, llm_parsed, llm_inferred
--   provenance_type: includes llm_inferred_low_confidence
--   regional_weight_tier: low, medium, high
--   seasonal_weight_tier: off_season, stable, approaching_peak, peak
--   equipment_type: vessel, heat_source, tool, appliance
--
-- All inserts in a single transaction.
-- ============================================================

BEGIN;

-- ============================================================
-- EQUIPMENT (5 new rows)
-- ============================================================

INSERT INTO equipment (id, name, equipment_type, thermal_property_notes, max_practical_temp_f, description, provenance) VALUES
  (gen_random_uuid(), 'copper_cazo_or_dutch_oven', 'vessel', 'Heavy thick-walled vessel for sustained high-heat lard confit; copper cazo is canonical Michoacán; enameled cast iron Dutch oven is acceptable.', 400, 'Traditional copper cazo for carnitas confit; Dutch oven is acceptable substitute.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'comal_or_flat_griddle', 'vessel', 'Flat heated surface for tortilla warming and salsa charring.', 500, 'Cast iron or steel comal (Mexican griddle) for dry-heat tortilla and salsa work.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'tortilla_press', 'tool', NULL, NULL, 'Hinged metal or wooden press for forming masa balls into tortilla rounds.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'blender_high_speed', 'appliance', NULL, NULL, 'High-speed blender for salsa preparation and other smooth blending.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'skimmer_or_slotted_spoon', 'tool', NULL, NULL, 'Mesh skimmer or slotted spoon for retrieving meat from hot lard.', 'llm_inferred_low_confidence');

-- ============================================================
-- TECHNIQUES (16 new rows)
-- ============================================================

INSERT INTO techniques (id, name, method_id, primary_equipment_id, secondary_equipment_id, temperature_range_f, duration_range, difficulty_tier, notes, provenance)
SELECT gen_random_uuid(), t.name, cm.id, eq1.id, eq2.id, t.temp, t.duration, t.difficulty::technique_difficulty, t.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('assembly_layered_taco', 'no_heat', 'mixing_bowl', NULL::text, NULL::text, '30 sec per taco', 'beginner', 'Place warm tortilla flat. Add carnitas. Top with onion, cilantro. Salsa on side or drizzled. Lime wedge alongside.'),
  ('cut_pork_into_2_inch_chunks_bone_in_acceptable', 'no_heat', 'chef_knife', NULL, NULL, '10 min', 'beginner', 'Cut pork into uniform 2-inch chunks. Bone-in pieces are traditional and contribute flavor; do not remove bones for carnitas.'),
  ('season_pork_with_salt_30min_minimum', 'no_heat', 'mixing_bowl', NULL, NULL, '30+ min', 'beginner', 'Season pork chunks with kosher salt. Rest 30 min minimum at room temp before confit. Helps surface dry for better fat penetration.'),
  ('render_or_melt_lard_in_heavy_pot_to_300F', 'fat_based', 'copper_cazo_or_dutch_oven', NULL, '300', '15 min', 'beginner', 'Melt manteca to 300F over medium heat. If using fresh-rendered, strain out any solid bits.'),
  ('submerge_pork_in_lard_at_275F_to_300F', 'fat_based', 'copper_cazo_or_dutch_oven', 'skimmer_or_slotted_spoon', '275-300', 'gradual', 'intermediate', 'Add pork chunks to hot lard gradually to avoid temperature crash. Pork should be fully submerged.'),
  ('confit_simmer_2_to_3_hours_until_tender', 'fat_based', 'copper_cazo_or_dutch_oven', NULL, '275', '2-3 hours', 'intermediate', 'Maintain steady temperature. Meat should bubble gently in lard, not boil violently. Stir occasionally to prevent sticking.'),
  ('add_milk_or_cola_aromatics_in_final_30min_for_caramelization', 'fat_based', 'copper_cazo_or_dutch_oven', NULL, '275', '30 min', 'intermediate', 'Add milk OR Coca-Cola plus aromatics (orange, garlic, bay, oregano, cumin) in final 30 min. Sugar and lactose contribute caramelization substrate for crispy-edge stage.'),
  ('increase_heat_to_350F_final_15min_for_crispy_edges', 'dry_heat', 'copper_cazo_or_dutch_oven', NULL, '350', '15 min', 'intermediate', 'Critical stage for carnitas identity. Increase heat. Edges of pork should brown and crisp. This is what makes carnitas distinct from generic pulled pork.'),
  ('drain_pork_reserving_lard_for_future_batches', 'no_heat', 'skimmer_or_slotted_spoon', NULL, NULL, '5 min', 'beginner', 'Lift pork from lard. Reserve lard; can be filtered and reused 2-3 batches. Flavor often improves with reuse.'),
  ('shred_or_chop_at_service', 'no_heat', 'chef_knife', NULL, NULL, '1 min per portion', 'beginner', 'Shred or roughly chop pork at service. Mix lean and fatty pieces for textural variety.'),
  ('warm_tortillas_on_dry_comal_or_griddle_30sec_per_side', 'dry_heat', 'comal_or_flat_griddle', NULL, '350', '60 sec total', 'beginner', 'Do NOT use oil; dry heat brings out corn flavor. Warming is mandatory; cold tortillas are bad tortillas.'),
  ('char_tomatillos_onion_garlic_chiles_on_comal_or_under_broiler', 'dry_heat', 'comal_or_flat_griddle', NULL, '400-500', '8-10 min', 'beginner', 'Char vegetables until skin is partially blackened. Develops smoky depth in salsa verde.'),
  ('blend_smooth_with_cilantro_salt_lime', 'no_heat', 'blender_high_speed', NULL, NULL, '1 min', 'beginner', 'Blend charred tomatillos, onion, garlic, chiles with cilantro, salt, lime juice until smooth. Adjust seasoning.'),
  ('mix_masa_with_water_salt_knead_5min', 'no_heat', 'mixing_bowl', NULL, NULL, '5 min', 'beginner', 'Mix masa harina with warm water and salt. Knead 5 min until smooth. Dough should be playdough-soft, not sticky or dry.'),
  ('divide_into_balls_press_in_tortilla_press', 'no_heat', 'tortilla_press', NULL, NULL, '30 sec each', 'beginner', 'Divide masa into 30g balls. Press between plastic sheets in tortilla press to ~6-inch round.'),
  ('cook_tortilla_on_comal_30sec_per_side_then_flip', 'dry_heat', 'comal_or_flat_griddle', NULL, '400', '90 sec total', 'beginner', 'Cook tortilla 30 sec, flip, 30 sec, flip again. Tortilla should puff slightly between flips. Wrap in towel to keep warm and pliable.')
) AS t(name, method_name, primary_eq_name, secondary_eq_name, temp, duration, difficulty, notes)
JOIN cooking_methods cm ON cm.name = t.method_name
JOIN equipment eq1 ON eq1.name = t.primary_eq_name
LEFT JOIN equipment eq2 ON eq2.name = t.secondary_eq_name;

-- ============================================================
-- CUISINE (1 new row)
-- ============================================================

INSERT INTO cuisines (id, name, parent_id, region_bias, description, provenance) VALUES
  (gen_random_uuid(), 'Mexican', NULL, 'North America (Mexico)', 'Mexican cuisine, encompassing strong regional sub-traditions: Michoacán, Oaxaca, Yucatán, Mexico City, Norteño, Veracruz, Puebla. Distinct from Tex-Mex (US-Mexico fusion) and Mexican-American hybrid styles.', 'llm_inferred_low_confidence');

-- ============================================================
-- INGREDIENTS (~22 new rows)
-- ============================================================

INSERT INTO ingredients (id, canonical_name, display_name, category_id, subcategory_id, default_unit, usda_commodity_code, description, provenance)
SELECT gen_random_uuid(), i.canonical_name, i.display_name, cat.id, NULL, i.default_unit, NULL, i.description, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  -- Pork cuts (multiple cuts for traditional carnitas)
  ('pork_shoulder_paleta_bone_in', 'Pork shoulder (paleta), bone-in', 'proteins', 'g', 'Pork shoulder cut, bone-in. Lean meat component of traditional carnitas mix. Spanish: paleta.'),
  ('pork_belly_for_carnitas', 'Pork belly, for carnitas', 'proteins', 'g', 'Skinless pork belly. Fat-rich component of traditional carnitas mix. Provides mouthfeel and lard contribution.'),
  ('pork_ribs_costilla', 'Pork ribs (costilla)', 'proteins', 'g', 'Pork rib pieces, bone-in. Adds bone marrow flavor to carnitas. Spanish: costilla.'),
  ('chicken_thigh_for_carnitas_pollo', 'Chicken thigh, for pollo carnitas', 'proteins', 'g', 'Boneless or bone-in chicken thigh as substitute for pork in pollo carnitas variant.'),
  -- Lard
  ('manteca_pork_lard', 'Manteca (pork lard)', 'fats_and_oils', 'g', 'Rendered pork fat. Traditional cooking medium for carnitas confit. Real fresh-rendered manteca from carnicerias is best; bagged industrial lard is acceptable.'),
  ('vegetable_shortening', 'Vegetable shortening', 'fats_and_oils', 'g', 'Hydrogenated vegetable fat. Substitute for manteca when pork lard unavailable; flavor change is real.'),
  -- Liquids and sweeteners for carnitas final stage
  ('milk_whole', 'Milk, whole', 'dairy', 'ml', 'Whole cow milk. Traditional addition to carnitas for caramelization stage; lactose contributes Maillard substrate.'),
  ('coca_cola', 'Coca-Cola', 'beverages_and_alcohol', 'ml', 'Coca-Cola soda. Michoacán street-vendor tradition for carnitas caramelization; sugar plus phosphoric acid contributes color and tang.'),
  -- Aromatics specific to carnitas
  ('orange_whole_skin_on', 'Orange, whole, skin-on', 'vegetables', 'each', 'Fresh orange, halved with skin on. Squeezed and added to carnitas pot; peel oils contribute aromatic depth, juice balances fat with acid.'),
  ('garlic_head_halved', 'Garlic, head, halved', 'vegetables', 'each', 'Whole garlic head halved across the equator; for carnitas pot aromatics.'),
  ('bay_leaves_dried', 'Bay leaves, dried', 'pantry', 'g', 'Dried bay leaves. Common Mexican carnitas aromatic.'),
  ('mexican_oregano_dried', 'Mexican oregano, dried (Lippia graveolens)', 'pantry', 'g', 'Mexican oregano (Lippia graveolens). DIFFERENT species from Mediterranean oregano (Origanum vulgare). Citrus-floral flavor profile, NOT thyme-pine. Not interchangeable in Mexican cuisine.'),
  ('mediterranean_oregano_dried', 'Mediterranean oregano, dried (Origanum vulgare)', 'pantry', 'g', 'Mediterranean oregano. Different species from Mexican oregano; thyme-pine flavor profile. Substitute when Mexican oregano unavailable; flavor change is real.'),
  ('cumin_seeds_whole', 'Cumin seeds, whole', 'pantry', 'g', 'Whole cumin seeds. Optional addition to carnitas; some regional traditions skip.'),
  ('white_onion_quartered', 'White onion, quartered', 'vegetables', 'g', 'White onion quartered for aromatic addition to carnitas pot.'),
  ('white_onion_finely_diced', 'White onion, finely diced', 'vegetables', 'g', 'White onion in fine dice. Canonical raw onion garnish for tacos.'),
  -- Tortillas
  ('corn_tortillas_fresh_tortilleria', 'Corn tortillas, fresh (tortilleria-grade)', 'pantry', 'g', 'Fresh corn tortillas from tortilleria or quality brand (Mi Tienda, El Milagro, La Banderita). Soft, pliable, with corn flavor.'),
  ('corn_tortillas_mass_market', 'Corn tortillas, mass-market', 'pantry', 'g', 'Mass-market shelf-stable corn tortillas. Lower quality; rubber-like texture, breaks under filling weight.'),
  ('masa_harina_maseca', 'Masa harina (Maseca or equivalent)', 'pantry', 'g', 'Nixtamalized corn flour for from-scratch tortillas. Maseca is most widely available brand.'),
  -- Salsa ingredients
  ('tomatillos_fresh_husks_removed', 'Tomatillos, fresh, husks removed', 'vegetables', 'g', 'Fresh tomatillos, husks removed and rinsed. Base for salsa verde.'),
  ('serrano_chiles_fresh', 'Serrano chiles, fresh', 'vegetables', 'g', 'Fresh serrano chiles. Sharper and slightly hotter than jalapeño. Standard for salsa verde.'),
  -- Garnish-specific
  ('radish_thinly_sliced', 'Radish, thinly sliced', 'vegetables', 'g', 'Fresh red radish, thin slices. Optional traditional Mexican palate cleanser for tacos.'),
  -- Optional toppings
  ('mexican_crema', 'Mexican crema', 'dairy', 'ml', 'Mexican-style cultured cream. Lighter than sour cream, more like crème fraîche. Optional regional variant.'),
  ('cotija_or_queso_fresco_crumbled', 'Cotija or queso fresco, crumbled', 'dairy', 'g', 'Mexican aged white cheese (cotija) or fresh white cheese (queso fresco), crumbled. More common in Tex-Mex than traditional Mexican carnitas.'),
  ('avocado_or_guacamole', 'Avocado or guacamole', 'vegetables', 'g', 'Fresh avocado sliced or mashed into guacamole. More Mexican-American than traditional Mexican carnitas, but widely accepted.'),
  ('hot_sauce_cholula_tapatio_valentina', 'Hot sauce (Cholula, Tapatío, or Valentina)', 'sauces_and_condiments', 'ml', 'Mexican hot sauce. Cholula (red, mild), Tapatío (vinegar-forward), Valentina (most traditional, balanced). Optional table condiment.')
) AS i(canonical_name, display_name, category_name, default_unit, description)
JOIN ingredient_categories cat ON cat.name = i.category_name;

-- ============================================================
-- INGREDIENT ALIASES (Spanish-English mappings)
-- ============================================================

INSERT INTO ingredient_aliases (id, ingredient_id, alias_name, language, region_origin, notes, provenance)
SELECT gen_random_uuid(), ing.id, a.alias_name, a.language, a.region_origin, a.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('pork_shoulder_paleta_bone_in', 'paleta', 'es', 'Mexico', 'Spanish name for pork shoulder.'),
  ('pork_shoulder_paleta_bone_in', 'pork butt', 'en', 'US butcher usage', 'American butcher term, despite the name referring to shoulder.'),
  ('pork_ribs_costilla', 'costilla de cerdo', 'es', 'Mexico', 'Full Spanish name.'),
  ('pork_ribs_costilla', 'pork spare ribs', 'en', 'global', 'English equivalent.'),
  ('manteca_pork_lard', 'manteca de cerdo', 'es', 'Mexico', 'Full Spanish name.'),
  ('manteca_pork_lard', 'rendered pork fat', 'en', 'global', 'Functional English description.'),
  ('mexican_oregano_dried', 'orégano mexicano', 'es', 'Mexico', 'Spanish name.'),
  ('mexican_oregano_dried', 'Lippia graveolens', 'la', 'scientific', 'Botanical name; distinct from Origanum vulgare.'),
  ('mediterranean_oregano_dried', 'Origanum vulgare', 'la', 'scientific', 'Botanical name.'),
  ('tomatillos_fresh_husks_removed', 'tomate verde', 'es', 'Mexico', 'Spanish name; literally "green tomato" though botanically distinct from tomatoes.'),
  ('tomatillos_fresh_husks_removed', 'husk tomato', 'en', 'common usage', 'English description.'),
  ('serrano_chiles_fresh', 'chile serrano', 'es', 'Mexico', 'Full Spanish name.'),
  ('mexican_crema', 'crema mexicana', 'es', 'Mexico', 'Full Spanish name.'),
  ('mexican_crema', 'Mexican sour cream', 'en', 'common usage', 'Generic English description, though crema is lighter than sour cream.'),
  ('cotija_or_queso_fresco_crumbled', 'queso cotija', 'es', 'Mexico', 'Spanish name for aged crumbly Mexican cheese.'),
  ('cotija_or_queso_fresco_crumbled', 'queso fresco', 'es', 'Mexico', 'Spanish name for fresh white Mexican cheese; distinct from cotija but often interchangeable in tacos.')
) AS a(canonical_name, alias_name, language, region_origin, notes)
JOIN ingredients ing ON ing.canonical_name = a.canonical_name;

-- ============================================================
-- DISH (1 new row)
-- ============================================================

INSERT INTO dishes (id, name, cuisine_id, archetype_id, description, complexity_tier, provenance)
SELECT gen_random_uuid(), 'Carnitas tacos (Michoacán-style)', c.id, NULL,
  'Traditional Michoacán-style carnitas tacos. Pork (mix of shoulder, belly, and ribs) confited in manteca (pork lard) for 2-3 hours, with caramelization stage using milk or Coca-Cola, finished at higher heat for crispy edges. Served on fresh corn tortillas with raw white onion, cilantro, salsa verde (default; salsa roja or chile de árbol as variants), and lime wedges. NOT a braise; the lard-confit IS the dish identity. Canonical anti-pattern: "carnitas" cooked in stock or water is not real carnitas.',
  'intermediate'::complexity_tier, 'llm_inferred_low_confidence'::provenance_type
FROM cuisines c WHERE c.name = 'Mexican';

-- ============================================================
-- RECIPES (5 rows: 1 parent + 4 sub-recipes)
-- ============================================================

INSERT INTO recipes (id, dish_id, title, source, source_url, instructions, yield_quantity, yield_unit, complexity_tier, submitted_by_user_id, provenance, validity_window_end_date)
SELECT gen_random_uuid(), d.id, r.title, r.source, NULL, r.instructions, r.yield_qty, r.yield_unit, r.complexity::complexity_tier, NULL, 'llm_inferred_low_confidence'::provenance_type, r.validity_end::date
FROM (VALUES
  ('Carnitas tacos (Michoacán-style, Houston metro April 2026)', 'Engine B v1.1 decomposition', 'Warm 3 corn tortillas on dry comal 30 sec per side. Place flat. Top each with ~80g shredded carnitas. Garnish with finely diced white onion and fresh chopped cilantro. Drizzle salsa verde (or serve on side). Serve with lime wedges.', 1, 'plate (3 tacos)', 'basic_prep', '2026-06-30'),
  ('Carnitas (lard-confit pork)', 'Engine B v1.1 decomposition', 'Cut mixed pork (shoulder + belly + ribs) into 2-inch chunks. Salt and rest 30 min. Melt manteca to 300F in heavy pot. Submerge pork; confit at 275F for 2-3 hours. In final 30 min add milk OR Coca-Cola plus orange halves, garlic, bay, oregano, cumin, onion. Final 15 min: increase to 350F for crispy edges (critical stage). Drain pork, reserve lard for future batches. Shred at service.', 2000, 'g', 'intermediate', NULL),
  ('Corn tortilla preparation (warmed)', 'Engine B v1.1 decomposition', 'For pre-made tortillas: warm on dry comal at 350F, 30 sec per side. Wrap in towel to keep warm and pliable. For from-scratch: mix masa harina with warm water and salt, knead 5 min. Divide into 30g balls. Press in tortilla press. Cook on comal 30 sec, flip, 30 sec, flip again until puffed.', 3, 'tortillas', 'basic_prep', NULL),
  ('Salsa verde (charred-tomatillo)', 'Engine B v1.1 decomposition', 'Char tomatillos, white onion, garlic cloves, and serrano chiles on comal or under broiler 8-10 min until skin is partially blackened. Transfer to high-speed blender with cilantro, salt, lime juice. Blend smooth. Adjust seasoning.', 600, 'ml', 'basic_prep', NULL),
  ('Garnish (raw onion, cilantro, lime)', 'Engine B v1.1 decomposition', 'Finely dice white onion. Chop cilantro (small leaves and tender stems). Cut lime into wedges. Assemble at service.', 1, 'plate', 'basic_prep', NULL)
) AS r(title, source, instructions, yield_qty, yield_unit, complexity, validity_end)
LEFT JOIN dishes d ON d.name = 'Carnitas tacos (Michoacán-style)' AND r.title LIKE 'Carnitas tacos%';

-- ============================================================
-- RECIPE_INGREDIENTS
-- ============================================================

-- Carnitas (lard-confit pork) sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('pork_shoulder_paleta_bone_in', 1200::numeric, 'g', 'cut into 2-inch chunks, bone-in acceptable'::text, 'primary_protein', false, 'Lean meat component, ~60% of mix.'::text),
  ('pork_belly_for_carnitas', 600, 'g', 'cut into 2-inch chunks', 'primary_protein', false, 'Fat-rich component, ~30% of mix.'),
  ('pork_ribs_costilla', 200, 'g', 'cut into rib-sized pieces', 'primary_protein', false, 'Bone-in flavor component, ~10% of mix.'),
  ('manteca_pork_lard', 1500, 'g', 'enough to fully submerge meat', 'flavor_fat', false, 'Cooking medium AND flavor contributor; do not skimp.'),
  ('fine_sea_salt', 25, 'g', 'kosher or sea, applied 30 min before confit', 'salt_seasoning', false, NULL),
  ('milk_whole', 250, 'ml', 'added in final 30 min', 'sweetener', false, 'Default caramelization addition. Coca-Cola is street-vendor variant.'),
  ('orange_whole_skin_on', 1, 'each', 'halved, juice and peel both added', 'acid', false, 'Peel oils and juice both contribute to flavor.'),
  ('garlic_head_halved', 1, 'each', 'halved across equator', 'aromatic_base', false, NULL),
  ('bay_leaves_dried', 1.5, 'g', '3 leaves', 'aromatic_base', false, NULL),
  ('mexican_oregano_dried', 5, 'g', NULL, 'spice_base', false, 'Mexican oregano specifically; not interchangeable with Mediterranean.'),
  ('cumin_seeds_whole', 5, 'g', NULL, 'spice_base', true, 'Optional; regional choice.'),
  ('white_onion_quartered', 200, 'g', 'medium, quartered', 'aromatic_base', false, NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Carnitas (lard-confit pork)';

-- Corn tortilla preparation sub-recipe (default = pre-made; from-scratch ingredients listed for variant)
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('corn_tortillas_fresh_tortilleria', 75::numeric, 'g', '3 tortillas, ~25g each, warmed on dry comal'::text, 'starch_base', false, 'Default = pre-made fresh tortilleria-grade.'::text),
  ('masa_harina_maseca', 200, 'g', 'for from-scratch variant', 'dough_structure', true, 'Only needed for from-scratch tortillas.'),
  ('water_room_temp', 250, 'ml', 'warm, for from-scratch variant', 'cooking_liquid', true, NULL),
  ('fine_sea_salt', 2, 'g', 'for from-scratch variant', 'salt_seasoning', true, NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Corn tortilla preparation (warmed)';

-- Salsa verde sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('tomatillos_fresh_husks_removed', 500::numeric, 'g', 'husks removed, rinsed'::text, 'vegetable_substance', NULL::text),
  ('white_onion_quartered', 50, 'g', 'roughly chopped', 'aromatic_base', NULL),
  ('garlic_minced', 9, 'g', '3 cloves', 'aromatic_base', NULL),
  ('serrano_chiles_fresh', 20, 'g', '2-3 chiles, adjust for heat', 'heat_component', NULL),
  ('cilantro_fresh_sprigs', 30, 'g', 'leaves and tender stems', 'aromatic_finishing', NULL),
  ('fine_sea_salt', 4, 'g', NULL, 'salt_seasoning', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Salsa verde (charred-tomatillo)';

-- Garnish sub-recipe ingredients
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('white_onion_finely_diced', 30::numeric, 'g', 'fine dice'::text, 'aromatic_finishing', 'White onion canonical for tacos.'::text),
  ('cilantro_fresh_sprigs', 15, 'g', 'finely chopped, leaves and tender stems', 'aromatic_finishing', NULL)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Garnish (raw onion, cilantro, lime)';

-- ============================================================
-- RECIPE_SUB_RECIPES
-- ============================================================

INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, link.qty, link.unit, link.step_order, false, link.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Carnitas tacos (Michoacán-style, Houston metro April 2026)', 'Carnitas (lard-confit pork)', 'primary_protein', 250::numeric, 'g', 3, '~80g per taco x 3.'::text),
  ('Carnitas tacos (Michoacán-style, Houston metro April 2026)', 'Corn tortilla preparation (warmed)', 'starch_base', 75, 'g', 1, '3 tortillas warmed.'),
  ('Carnitas tacos (Michoacán-style, Houston metro April 2026)', 'Salsa verde (charred-tomatillo)', 'condiment_component', 30, 'ml', 6, 'Drizzled or served on side.'),
  ('Carnitas tacos (Michoacán-style, Houston metro April 2026)', 'Garnish (raw onion, cilantro, lime)', 'aromatic_finishing', 50, 'g', 5, 'Onion and cilantro on top; lime wedges alongside.')
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
  ('Carnitas tacos (Michoacán-style, Houston metro April 2026)', 'assembly_layered_taco', 1, NULL::text),
  -- Carnitas sub-recipe
  ('Carnitas (lard-confit pork)', 'cut_pork_into_2_inch_chunks_bone_in_acceptable', 1, NULL),
  ('Carnitas (lard-confit pork)', 'season_pork_with_salt_30min_minimum', 2, NULL),
  ('Carnitas (lard-confit pork)', 'render_or_melt_lard_in_heavy_pot_to_300F', 3, NULL),
  ('Carnitas (lard-confit pork)', 'submerge_pork_in_lard_at_275F_to_300F', 4, NULL),
  ('Carnitas (lard-confit pork)', 'confit_simmer_2_to_3_hours_until_tender', 5, NULL),
  ('Carnitas (lard-confit pork)', 'add_milk_or_cola_aromatics_in_final_30min_for_caramelization', 6, NULL),
  ('Carnitas (lard-confit pork)', 'increase_heat_to_350F_final_15min_for_crispy_edges', 7, 'Critical stage for carnitas identity.'),
  ('Carnitas (lard-confit pork)', 'drain_pork_reserving_lard_for_future_batches', 8, NULL),
  ('Carnitas (lard-confit pork)', 'shred_or_chop_at_service', 9, NULL),
  -- Tortilla preparation
  ('Corn tortilla preparation (warmed)', 'warm_tortillas_on_dry_comal_or_griddle_30sec_per_side', 1, 'Default for pre-made.'),
  ('Corn tortilla preparation (warmed)', 'mix_masa_with_water_salt_knead_5min', 2, 'From-scratch variant.'),
  ('Corn tortilla preparation (warmed)', 'divide_into_balls_press_in_tortilla_press', 3, 'From-scratch variant.'),
  ('Corn tortilla preparation (warmed)', 'cook_tortilla_on_comal_30sec_per_side_then_flip', 4, 'From-scratch variant.'),
  -- Salsa verde
  ('Salsa verde (charred-tomatillo)', 'char_tomatillos_onion_garlic_chiles_on_comal_or_under_broiler', 1, NULL),
  ('Salsa verde (charred-tomatillo)', 'blend_smooth_with_cilantro_salt_lime', 2, NULL)
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
  -- 1. Anti-substitution: braising vs lard-confit
  ('manteca_pork_lard', 'manteca_pork_lard', 'flavor_fat', 'Mexican',
   'technique_simplification', 'technique_swap', 0.20::numeric, 'cheaper', NULL::text,
   'ENGINE WARNING: braising in stock or water is NOT carnitas.',
   'Anti-substitution. Lose: carnitas signature flavor, lard-fried richness, crispy edges from final stage. This becomes "braised pork", not carnitas. Gain: less fat, easier kitchen workflow. Compensate: minimal; the lard-confit IS the dish. When appropriate: never for carnitas. When NOT appropriate: any "carnitas" menu claim. The Mexican-Spanish word means "little meats" cooked in lard.',
   'medium', 'stable'),
  -- 2. Manteca to vegetable shortening
  ('manteca_pork_lard', 'vegetable_shortening', 'flavor_fat', 'Mexican',
   'dietary_restriction', 'ingredient_swap', 0.40, 'cheaper', NULL,
   'Flavor change is real; pork lard contributes pork-specific savory notes that shortening lacks.',
   'Lose: pork lard contribution to flavor; rendered manteca has pork-specific savory notes. Gain: vegetarian-substrate option (does not make dish vegetarian; meat is still pork). Compensate: minimal; flavor change is real. When appropriate: when pork lard is unavailable. When NOT appropriate: in Houston where manteca is abundant; this swap is unnecessary.',
   'low', 'stable'),
  -- 3. Milk to Coca-Cola for caramelization
  ('milk_whole', 'coca_cola', 'sweetener', 'Mexican',
   'cuisine_translation', 'ingredient_swap', 0.85, 'similar', NULL,
   'Reduce cooking time slightly; cola has more sugar and caramelizes faster.',
   'Lose: dairy-driven richness, white-fat caramelization. Gain: phosphoric acid contributes specific tang; sugar plus caramel from cola adds darker color and complex sweetness; iconic Michoacán street-vendor signature. When appropriate: street-style positioning, Michoacán-style menu, broader market appeal. When NOT appropriate: ultra-traditional purist positioning that prefers milk.',
   'high', 'stable'),
  -- 4. Pork shoulder only to mixed cuts (quality up)
  ('pork_shoulder_paleta_bone_in', 'pork_belly_for_carnitas', 'primary_protein', 'Mexican',
   'quality_improvement', 'ingredient_swap', 0.95, 'more_expensive', NULL,
   'Use 60/30/10 mix shoulder/belly/ribs for traditional carnitas vendor result.',
   'Lose: cost-effectiveness, simpler shopping. Gain: textural and flavor complexity (lean+fatty+bone-in); this is what real carnitas vendors use. Compensate: pricing must adjust; bone-in adds prep time. When appropriate: any operation positioning on carnitas authenticity. When NOT appropriate: high-volume cost-driven operations.',
   'high', 'stable'),
  -- 5. Pork shoulder only to chicken thigh (pollo)
  ('pork_shoulder_paleta_bone_in', 'chicken_thigh_for_carnitas_pollo', 'primary_protein', 'Mexican',
   'dietary_restriction', 'ingredient_swap', 0.55, 'cheaper', NULL,
   'Reduce cook time to 60-90 min; use chicken thigh (not breast); lower lard temperature to 250F.',
   'Lose: pork richness; chicken cooks faster and absorbs less fat. Gain: poultry option, lower cost, halal-compatible. When appropriate: explicit "pollo carnitas" menu item; halal-positioning. When NOT appropriate: claiming "carnitas" without qualifier; carnitas means pork.',
   'high', 'stable'),
  -- 6. Mass-market tortillas to fresh tortilleria
  ('corn_tortillas_mass_market', 'corn_tortillas_fresh_tortilleria', 'starch_base', 'Mexican',
   'quality_improvement', 'ingredient_swap', 0.90, 'more_expensive', NULL, NULL,
   'Lose: convenience of grocery aisle pickup, longer shelf life. Gain: corn flavor, pliable texture, taco does not break under filling weight. Compensate: need to buy frequently (1-2 day shelf life). When appropriate: any operation positioning on taco quality. When NOT appropriate: high-volume operations buying frozen.',
   'high', 'stable'),
  -- 7. Salsa verde to salsa roja
  ('tomatillos_fresh_husks_removed', 'tomato_beefsteak_slicing', 'vegetable_substance', 'Mexican',
   'cuisine_translation', 'ingredient_swap', 0.70, 'similar', NULL,
   'Add 15 ml lime juice to salsa roja to compensate for missing tomatillo acidity.',
   'Lose: tomatillo bright acidity that cuts pork fat. Gain: deeper roasted-tomato flavor, richer mouthfeel. When appropriate: customer preference, regional Mexico City style. When NOT appropriate: when fat-cutting acidity is the menu position.',
   'high', 'stable'),
  -- 8. Mexican oregano to Mediterranean oregano
  ('mexican_oregano_dried', 'mediterranean_oregano_dried', 'spice_base', 'Mexican',
   'availability_swap', 'ingredient_swap', 0.50, 'similar', NULL,
   'Real flavor change; Mediterranean is grassier and more savory than Mexican oregano citrus-floral profile.',
   'Lose: Mexican oregano citrus-floral character (Lippia graveolens). Gain: nothing in carnitas context. Compensate: this is a real flavor change. When appropriate: rarely; Mexican oregano is widely available in Houston. When NOT appropriate: claiming Mexican authenticity.',
   'low', 'stable'),
  -- 9. Confit in lard to slow cooker / Instant Pot
  ('manteca_pork_lard', 'manteca_pork_lard', 'flavor_fat', 'Mexican',
   'technique_simplification', 'technique_swap', 0.65, 'similar', NULL,
   'After slow cooker stage, transfer pork to skillet with reserved lard, fry edges 10 min before service. Recovers most of the texture loss.',
   'Lose: crispy edges from final high-heat stage; controlled lard environment. Gain: hands-off cooking, batch-friendly. Compensate: post-cook crispy stage in skillet. When appropriate: food truck operations, home cooks, low-volume restaurants. When NOT appropriate: traditional carnitas claim; the cazo-confit method IS the dish.',
   'high', 'stable'),
  -- 10. Anti-substitution: skip crispy stage
  ('pork_shoulder_paleta_bone_in', 'pork_shoulder_paleta_bone_in', 'primary_protein', 'Mexican',
   'technique_simplification', 'technique_swap', 0.20, 'similar', NULL,
   'ENGINE WARNING: skipping the crispy-edge stage produces "Mexican-seasoned pulled pork", not carnitas.',
   'Anti-pattern flag. The crispy-edges stage at 350F for final 15 min IS what makes carnitas distinctive from generic pulled pork. Lose: carnitas identity. Gain: nothing relevant. Compensate: do not skip the final crisp stage. When appropriate: never. When NOT appropriate: always avoid skipping.',
   'high', 'stable'),
  -- 11. Salsa verde to salsa de chile de árbol
  ('tomatillos_fresh_husks_removed', 'serrano_chiles_fresh', 'vegetable_substance', 'Mexican',
   'cuisine_translation', 'ingredient_swap', 0.65, 'similar', NULL,
   'Replace tomatillo base with dried chile de árbol; serve alongside lime wedges to maintain acid balance.',
   'Lose: salsa verde herbal cilantro character. Gain: smoky dried-chile heat, authentic Mexican depth. Compensate: serve alongside lime wedges. When appropriate: heat-forward menu position, Mexican-purist customers. When NOT appropriate: customers preferring milder herbal salsas.',
   'medium', 'stable')
) AS s(orig_canonical, sub_canonical, role_name, cuisine_name, purpose, kind, quality_score, cost_dir, alt_tech_name, technique_notes, tradeoff_notes, regional, seasonal)
JOIN ingredients orig ON orig.canonical_name = s.orig_canonical
JOIN ingredients sub ON sub.canonical_name = s.sub_canonical
JOIN ingredient_roles role ON role.name = s.role_name
JOIN cuisines cuis ON cuis.name = s.cuisine_name
LEFT JOIN techniques alt_tech ON alt_tech.name = s.alt_tech_name;

COMMIT;
