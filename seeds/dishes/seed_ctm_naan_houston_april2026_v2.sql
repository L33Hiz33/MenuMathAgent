-- ============================================================
-- Seed: Chicken tikka masala (British-Indian) + Naan (North Indian)
-- Houston metro, April 2026
-- v2 CORRECTED: butter_unsalted removed from ingredients INSERT
-- (already exists from cheeseburger seed). recipe_ingredients
-- references resolve via canonical_name JOIN to existing row.
--
-- v1.2 substitution framework:
--   real_substitution: 10 rows
--   anti_pattern: 4 rows
--   dish_variants: 5 (murgh makhani, garlic/peshwari/keema naan, roti)
--                  NOT inserted; flagged in comments for dish_relationships
--
-- All inserts in a single transaction. Provenance: llm_inferred_low_confidence.
-- ============================================================

BEGIN;

-- ============================================================
-- EQUIPMENT (3 new rows)
-- ============================================================

INSERT INTO equipment (id, name, equipment_type, thermal_property_notes, max_practical_temp_f, description, provenance) VALUES
  (gen_random_uuid(), 'pizza_stone_or_baking_steel', 'vessel', 'Heat-retaining stone or steel for high-temperature oven baking; alternative to tandoor for naan.', 600, 'Pizza stone or baking steel preheated in 550F oven; produces tandoor-approximate naan bottom crust.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'skewers_metal_or_bamboo', 'tool', NULL, NULL, 'Metal or bamboo skewers for tikka grilling; bamboo soaked 30 min before use.', 'llm_inferred_low_confidence'),
  (gen_random_uuid(), 'spice_grinder_or_mortar', 'appliance', NULL, NULL, 'Dedicated coffee-grinder or mortar and pestle for grinding whole toasted spices; small-batch fresh grind preferred over pre-ground commercial spices.', 'llm_inferred_low_confidence');

-- ============================================================
-- TECHNIQUES (~30 new rows)
-- ============================================================

INSERT INTO techniques (id, name, method_id, primary_equipment_id, secondary_equipment_id, temperature_range_f, duration_range, difficulty_tier, notes, provenance)
SELECT gen_random_uuid(), t.name, cm.id, eq1.id, eq2.id, t.temp, t.duration, t.difficulty::technique_difficulty, t.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('mince_or_paste_ginger_garlic', 'no_heat', 'chef_knife', NULL::text, NULL::text, '5 min', 'beginner', 'Mince or paste ginger and garlic together (adrak-lehsun paste). Equal parts by weight is canonical North Indian ratio.'),
  ('whisk_yogurt_smooth', 'no_heat', 'mixing_bowl', NULL, NULL, '1 min', 'beginner', 'Whisk yogurt until smooth and pourable; breaks up any lumps before mixing with spices.'),
  ('combine_marinade_ingredients_until_uniform', 'no_heat', 'mixing_bowl', NULL, NULL, '3 min', 'beginner', 'Combine yogurt, ginger-garlic paste, spices, salt, oil, lemon juice. Mix until uniformly colored.'),
  ('coat_chicken_thoroughly_marinate_4_to_24_hours', 'no_heat', 'mixing_bowl', NULL, '35-40', '4-24 hours', 'beginner', 'Coat chicken thoroughly in marinade. Refrigerate covered. Minimum 4 hours; 12-24 hours is best. Yogurt enzymes tenderize the meat.'),
  ('toast_whole_spices_dry_pan_until_fragrant', 'dry_heat', 'cast_iron_pan_heavy', NULL, '300-350', '2-3 min', 'intermediate', 'Toast whole spices in dry pan, agitating constantly. Stop when fragrant and slightly darker, before any browning. Burning ruins the batch.'),
  ('cool_spices_completely_before_grinding', 'no_heat', 'mixing_bowl', NULL, NULL, '10 min', 'beginner', 'Spread toasted spices on cool plate; cool fully before grinding. Hot spices steam in grinder, ruining the powder texture.'),
  ('grind_to_fine_powder_in_spice_grinder', 'no_heat', 'spice_grinder_or_mortar', NULL, NULL, '1 min', 'beginner', 'Grind cooled spices in dedicated grinder or mortar to fine powder. Sift through fine mesh to remove larger pieces if desired.'),
  ('saute_onion_in_butter_or_ghee_until_golden_15_to_20min', 'fat_based', 'cast_iron_pan_heavy', NULL, '300-350', '15-20 min', 'intermediate', 'Sauté finely chopped onion in butter or ghee over medium heat. Stir occasionally. Goal: deep golden brown caramelization, NOT just translucent. The 15-20 min is dish-defining; rushing produces watery sauce.'),
  ('add_garlic_ginger_cook_2min', 'fat_based', 'cast_iron_pan_heavy', NULL, '300', '2 min', 'beginner', 'Add ginger-garlic paste to caramelized onions. Cook stirring constantly to prevent burning until raw smell dissipates.'),
  ('add_dry_spices_bloom_in_fat_30sec', 'fat_based', 'cast_iron_pan_heavy', NULL, '300', '30 sec', 'intermediate', 'Add ground spices to hot fat with onions. Stir constantly 30 seconds; fat extracts fat-soluble flavor compounds. Critical step; do not rush, do not burn.'),
  ('add_tomato_paste_cook_2min', 'fat_based', 'cast_iron_pan_heavy', NULL, '300', '2 min', 'beginner', 'Add tomato paste; cook stirring 2 min until darkened slightly. Concentrates the umami contribution.'),
  ('add_passata_simmer_15min', 'wet_heat', 'cast_iron_pan_heavy', NULL, '212-220', '15 min', 'beginner', 'Add tomato passata or crushed tomatoes; simmer uncovered 15 min. Sauce reduces and concentrates.'),
  ('blend_sauce_smooth_or_leave_chunky_per_style', 'no_heat', 'blender_high_speed', NULL, NULL, '1 min', 'intermediate', 'British-Indian CTM is typically blended smooth using immersion blender or stand blender. Some Indian variants leave the sauce chunky. Choose per menu positioning.'),
  ('add_cream_simmer_5min', 'wet_heat', 'cast_iron_pan_heavy', NULL, '180-200', '5 min', 'beginner', 'Stir in heavy cream. Simmer gently 5 min over low heat; do NOT boil (cream breaks). Sauce should slightly thicken.'),
  ('finish_with_kasoori_methi_off_heat', 'no_heat', 'cast_iron_pan_heavy', NULL, NULL, '30 sec', 'beginner', 'Crush kasoori methi between palms to release aromatics. Stir into sauce OFF heat. Volatile aromatics are preserved by avoiding direct cooking.'),
  ('preheat_broiler_or_grill_to_high', 'dry_heat', 'broiler_oven', NULL, '500-550', '5 min', 'beginner', 'Preheat broiler or grill to highest setting. Surface should be screaming hot before chicken enters.'),
  ('arrange_marinated_chicken_on_skewers_or_sheet_pan', 'no_heat', 'skewers_metal_or_bamboo', NULL, NULL, '5 min', 'beginner', 'Thread chicken on skewers or arrange on lined sheet pan with space between pieces. Single layer, not crowded.'),
  ('broil_or_grill_until_charred_edges_8_to_10min', 'dry_heat', 'broiler_oven', 'skewers_metal_or_bamboo', '500-550', '8-10 min', 'intermediate', 'Broil or grill rotating every 3-4 min. Aim for actual char on edges, not just cooked through. Maillard depth defines tikka. Internal temp 165F.'),
  ('rest_briefly_2min', 'no_heat', 'mixing_bowl', NULL, NULL, '2 min', 'beginner', 'Rest grilled chicken 2 min. Juices redistribute before sauce integration.'),
  ('combine_with_sauce_simmer_5min', 'wet_heat', 'cast_iron_pan_heavy', NULL, '180-200', '5 min', 'beginner', 'Add rested grilled chicken to finished sauce. Brief simmer integrates flavors without overcooking the already-cooked chicken.'),
  ('simmer_in_sauce_after_grill_or_broil', 'wet_heat', 'cast_iron_pan_heavy', NULL, '180-200', '5 min', 'beginner', 'Top-level CTM technique: marinade + grill/broil + integrate with sauce. Final brief simmer.'),
  ('bloom_yeast_in_warm_water_with_sugar_5min', 'no_heat', 'mixing_bowl', NULL, '105-110', '5 min', 'beginner', 'Combine yeast with warm water and sugar; let stand 5 min until foamy. Confirms yeast is alive.'),
  ('combine_dry_then_wet_ingredients_in_stand_mixer_or_by_hand', 'no_heat', 'mixing_bowl', NULL, NULL, '3 min', 'beginner', 'Combine dry ingredients (flour, salt, baking powder) in mixer bowl. Add wet (bloomed yeast, yogurt, egg, oil) and mix until shaggy.'),
  ('knead_until_smooth_8_to_10min', 'no_heat', 'mixing_bowl', NULL, NULL, '8-10 min', 'intermediate', 'Knead by hand or mixer hook until smooth, elastic, slightly tacky. Window pane test: dough should stretch thin without tearing.'),
  ('proof_covered_2_to_3_hours_until_doubled', 'no_heat', 'mixing_bowl', NULL, '75-80', '2-3 hours', 'beginner', 'Proof in oiled bowl, covered, in warm spot until doubled in volume. Slower cool proof develops better flavor.'),
  ('divide_into_balls_100g_each', 'no_heat', 'chef_knife', NULL, NULL, '5 min', 'beginner', 'Divide proofed dough into 100g balls; round into smooth ball shape on lightly floured surface.'),
  ('rest_balls_15min_before_shaping', 'no_heat', 'mixing_bowl', NULL, NULL, '15 min', 'beginner', 'Cover balls with damp cloth; rest 15 min to relax gluten before shaping.'),
  ('shape_naan_by_stretching_into_teardrop', 'no_heat', 'mixing_bowl', NULL, NULL, '30 sec', 'intermediate', 'Stretch ball by hand into teardrop or oval shape, ~8 inch length. Do NOT use rolling pin; preserves air pockets in dough.'),
  ('bake_in_tandoor_or_high_heat_alternative', 'dry_heat', 'pizza_stone_or_baking_steel', NULL, '550-700', '2-3 min', 'intermediate', 'Top-level naan technique: tandoor traditional; pizza stone in 550F oven or hot cast iron skillet are real alternatives.'),
  ('bake_on_pizza_stone_550F_2_to_3min', 'dry_heat', 'pizza_stone_or_baking_steel', NULL, '550', '2-3 min', 'intermediate', 'Slide stretched naan onto preheated pizza stone in 550F oven. Bake until puffed and lightly golden.'),
  ('broil_last_30sec_for_char', 'dry_heat', 'broiler_oven', NULL, '500-550', '30 sec', 'beginner', 'After baking, switch to broil for last 30 seconds to char the top. Watch carefully; goes from charred to burnt quickly.'),
  ('skillet_naan_60_to_90sec_per_side_in_hot_cast_iron', 'dry_heat', 'cast_iron_pan_heavy', NULL, '500', '90-120 sec', 'intermediate', 'Heat dry cast iron skillet very hot. Cook naan 60-90 sec per side; bubbles should form and char on contact points. Food truck friendly.'),
  ('brush_with_butter_or_ghee_at_service', 'no_heat', 'mixing_bowl', NULL, NULL, '15 sec', 'beginner', 'Brush hot naan with melted butter or ghee at service. Adds flavor and gloss.'),
  ('garnish_with_garlic_cilantro_nigella_optional', 'no_heat', 'mixing_bowl', NULL, NULL, '15 sec', 'beginner', 'Optional sprinkle: minced garlic (for garlic naan), chopped cilantro, nigella seeds. Apply before final char or after bake.')
) AS t(name, method_name, primary_eq_name, secondary_eq_name, temp, duration, difficulty, notes)
JOIN cooking_methods cm ON cm.name = t.method_name
JOIN equipment eq1 ON eq1.name = t.primary_eq_name
LEFT JOIN equipment eq2 ON eq2.name = t.secondary_eq_name;

-- ============================================================
-- CUISINE (1 new row)
-- ============================================================

INSERT INTO cuisines (id, name, parent_id, region_bias, description, provenance) VALUES
  (gen_random_uuid(), 'Indian', NULL, 'South Asia', 'Indian cuisine, encompassing strong regional sub-traditions: North Indian (Punjabi, Mughlai), South Indian (Tamil, Kerala, Andhra), East Indian (Bengali), West Indian (Gujarati, Marathi), Goan, Hyderabadi. British-Indian (Anglo-Indian) is a related fusion tradition. Distinct from Pakistani, Bangladeshi, and Sri Lankan cuisines despite shared elements.', 'llm_inferred_low_confidence');

-- ============================================================
-- INGREDIENTS (~29 new rows; butter_unsalted removed - already exists)
-- ============================================================

INSERT INTO ingredients (id, canonical_name, display_name, category_id, subcategory_id, default_unit, usda_commodity_code, description, provenance)
SELECT gen_random_uuid(), i.canonical_name, i.display_name, cat.id, NULL, i.default_unit, NULL, i.description, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  -- Dairy / fats
  ('yogurt_whole_milk_full_fat', 'Yogurt, whole milk, full-fat', 'dairy', 'g', 'Full-fat plain yogurt. Indian dahi traditional; full-fat Greek yogurt is acceptable substitute. Lactic acid tenderizes meat in marinade; provides body in sauce.'),
  ('ghee_clarified_butter', 'Ghee (clarified butter)', 'fats_and_oils', 'g', 'Clarified butter, milk solids removed. Higher smoke point than butter. Traditional North Indian cooking fat with nutty caramelized character.'),
  -- butter_unsalted REMOVED (already exists from cheeseburger seed)
  ('mustard_oil_indian', 'Mustard oil (Indian, kachi ghani)', 'fats_and_oils', 'ml', 'Cold-pressed mustard oil with characteristic pungent aroma. Traditional Punjabi cooking fat. Heat to smoking point before use to mellow pungency.'),
  ('heavy_cream_35_to_40_percent', 'Heavy cream (35-40% fat)', 'dairy', 'ml', 'Heavy cream at 35-40% fat content. Lower-fat creams break in long simmer. Used in CTM sauce and similar creamy curries.'),
  ('coconut_cream_full_fat', 'Coconut cream, full-fat', 'pantry', 'ml', 'Full-fat coconut cream from refrigerated can (not coconut milk). Vegan substitute for heavy cream.'),
  ('cashews_raw_for_cream_substitute', 'Cashews, raw (for cashew cream)', 'pantry', 'g', 'Raw unsalted cashews soaked in hot water 4 hours, blended smooth with water. Vegan dairy-cream substitute with very close mouthfeel.'),
  -- Aromatic vegetables
  ('onion_yellow_finely_chopped', 'Onion, yellow, finely chopped', 'vegetables', 'g', 'Yellow onion in fine chop for sauce base. White onion is also acceptable; red is sharper alternative.'),
  ('ginger_fresh_pasted', 'Ginger, fresh, pasted', 'vegetables', 'g', 'Fresh ginger root, peeled and pasted (or finely minced). Combined with garlic in equal weight as adrak-lehsun paste for North Indian aromatic base.'),
  -- Tomato products
  ('tomato_passata_or_crushed_canned', 'Tomato passata or crushed (canned)', 'pantry', 'g', 'Canned tomato passata (smooth) or crushed tomatoes. Pomi or San Marzano DOP-style brands acceptable. Forms the body of CTM sauce.'),
  ('tomato_paste_concentrated', 'Tomato paste, concentrated', 'pantry', 'g', 'Concentrated tomato paste from tube or can. Deepens tomato flavor and umami. Cooked in fat to develop.'),
  -- Spices
  ('green_cardamom_pods', 'Green cardamom pods', 'pantry', 'g', 'Green cardamom pods, whole. Floral-citrus profile. Critical in garam masala. Crush pods to release seeds.'),
  ('black_cardamom_pods', 'Black cardamom pods', 'pantry', 'g', 'Black (or brown) cardamom pods, whole. Smoky-camphor profile. Distinct from green; not interchangeable. Used in garam masala for depth.'),
  ('cinnamon_stick_true_ceylon', 'Cinnamon stick, true Ceylon', 'pantry', 'g', 'True Ceylon cinnamon (Cinnamomum verum). Gentler and more aromatic than cassia (Cinnamomum cassia). Cassia is harsher and most US "cinnamon" by default; true Ceylon is preferred for North Indian spice blends.'),
  ('cloves_whole', 'Cloves, whole', 'pantry', 'g', 'Whole cloves. Used in garam masala and biryani; potent so used sparingly.'),
  ('peppercorns_black_whole', 'Peppercorns, black, whole', 'pantry', 'g', 'Whole black peppercorns. Heat component in garam masala.'),
  ('cumin_seeds_whole_indian', 'Cumin seeds, whole', 'pantry', 'g', 'Whole cumin seeds (jeera). Different from black cumin (kala jeera) which is a separate spice. Cross-cuisine; used in Mexican, Middle Eastern, Indian cooking.'),
  ('coriander_seeds_whole', 'Coriander seeds, whole', 'pantry', 'g', 'Whole coriander seeds (dhania). Citrus-floral profile. Foundation of many Indian spice blends.'),
  ('fennel_seeds_whole', 'Fennel seeds, whole (saunf)', 'pantry', 'g', 'Whole fennel seeds. Sweet-anise note. Optional in garam masala; common in Punjabi blends.'),
  ('bay_leaves_indian_tej_patta', 'Bay leaves, Indian (tej patta)', 'pantry', 'g', 'Indian bay leaves (tej patta), distinct from Mediterranean bay (Laurus nobilis). Tej patta is from cassia tree, has cinnamon-clove notes. Some recipes use either; purists distinguish.'),
  ('mace_blade', 'Mace blade', 'pantry', 'g', 'Mace blades, the lacy covering of nutmeg. Nuanced floral note. Optional in premium garam masala.'),
  ('nutmeg_whole_for_grating', 'Nutmeg, whole (for grating)', 'pantry', 'g', 'Whole nutmeg for fresh grating. Pre-ground loses aromatics quickly.'),
  ('garam_masala_house_blend', 'Garam masala (house blend)', 'pantry', 'g', 'House-toasted garam masala from whole spices. Custom blend per kitchen tradition. Premium tier vs pre-made commercial.'),
  ('garam_masala_premade_mdh_or_everest', 'Garam masala, pre-made (MDH, Everest, or Shan brand)', 'pantry', 'g', 'Commercial pre-made garam masala. Functional; freshness varies by stock turnover. Buy small quantities, replace every 2-3 months.'),
  ('kashmiri_chili_powder', 'Kashmiri chili powder', 'pantry', 'g', 'Kashmiri red chili powder. Provides deep red color WITHOUT extreme heat. Defining ingredient for the rich red color of CTM and tandoori dishes. Substituting cayenne creates hotter dish without color benefit.'),
  ('turmeric_ground', 'Turmeric, ground', 'pantry', 'g', 'Ground turmeric (haldi). Bright yellow color, mild bitter, anti-inflammatory. Foundation Indian spice.'),
  ('cumin_ground', 'Cumin, ground', 'pantry', 'g', 'Ground cumin. Used in marinades and sauces. Pre-ground loses aromatics; replace every 6 months.'),
  ('coriander_ground', 'Coriander, ground', 'pantry', 'g', 'Ground coriander seed. Citrus-floral foundation spice.'),
  -- Critical CTM ingredient
  ('kasoori_methi_dried_fenugreek_leaves', 'Kasoori methi (dried fenugreek leaves)', 'pantry', 'g', 'Dried fenugreek leaves with bitter-grassy-maple aroma. CRITICAL ingredient in British-Indian CTM and butter chicken. Most American CTM skips this; result is recognizably less authentic. Crushed between palms before use to release volatile aromatics.'),
  -- Naan-specific
  ('flour_bread_high_protein', 'Flour, bread (high protein)', 'pantry', 'g', 'High-protein bread flour for naan dough. Develops chewier crumb. AP flour acceptable substitute with longer kneading.'),
  ('flour_all_purpose', 'Flour, all-purpose', 'pantry', 'g', 'All-purpose flour. Acceptable substitute for bread flour in naan, with softer result.'),
  ('yeast_active_dry', 'Yeast, active dry', 'pantry', 'g', 'Active dry yeast. Bloomed in warm water with sugar before mixing into dough.'),
  ('baking_powder_aluminum_free', 'Baking powder, aluminum-free', 'pantry', 'g', 'Standard double-acting baking powder. Optional addition to naan for extra rise alongside yeast.'),
  ('nigella_seeds_kalonji', 'Nigella seeds (kalonji)', 'pantry', 'g', 'Black nigella seeds, sometimes called black-onion seeds. Traditional sprinkle on plain naan. Slight pungent-onion aroma.'),
  -- Substitute / alternative ingredients
  ('chicken_thigh_boneless_skinless_for_tikka', 'Chicken thigh, boneless skinless (for tikka)', 'proteins', 'g', 'Boneless skinless chicken thigh. Standard for CTM tikka; juicier and more forgiving than breast.'),
  ('chicken_thigh_bone_in_for_tikka', 'Chicken thigh, bone-in (for tikka)', 'proteins', 'g', 'Bone-in chicken thigh. More traditional tandoor tikka; deeper flavor; longer cook.'),
  ('chicken_breast_boneless_skinless_for_tikka', 'Chicken breast, boneless skinless (for tikka)', 'proteins', 'g', 'Boneless skinless chicken breast. Leaner option; drier than thigh; requires careful cooking and brining for acceptable result.'),
  ('basmati_rice_aged_long_grain', 'Basmati rice, aged long-grain', 'pantry', 'g', 'Aged long-grain basmati rice. Traditional accompaniment to CTM. Soak 30 min before cooking.')
) AS i(canonical_name, display_name, category_name, default_unit, description)
JOIN ingredient_categories cat ON cat.name = i.category_name;

-- ============================================================
-- INGREDIENT ALIASES (Hindi-English-Punjabi)
-- ============================================================

INSERT INTO ingredient_aliases (id, ingredient_id, alias_name, language, region_origin, notes, provenance)
SELECT gen_random_uuid(), ing.id, a.alias_name, a.language, a.region_origin, a.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('yogurt_whole_milk_full_fat', 'dahi', 'hi', 'India', 'Hindi name for traditional Indian yogurt.'),
  ('ghee_clarified_butter', 'desi ghee', 'hi', 'India', 'Hindi name with "desi" indicating traditional origin.'),
  ('mustard_oil_indian', 'sarson ka tel', 'hi', 'India', 'Hindi name for mustard oil.'),
  ('mustard_oil_indian', 'kachi ghani', 'hi', 'India', 'Cold-pressed designation; more aromatic than refined mustard oil.'),
  ('ginger_fresh_pasted', 'adrak', 'hi', 'India', 'Hindi name for ginger.'),
  ('green_cardamom_pods', 'choti elaichi', 'hi', 'India', 'Hindi name for green cardamom.'),
  ('black_cardamom_pods', 'badi elaichi', 'hi', 'India', 'Hindi name for black cardamom.'),
  ('black_cardamom_pods', 'kali elaichi', 'hi', 'India', 'Alternate Hindi name.'),
  ('cumin_seeds_whole_indian', 'jeera', 'hi', 'India', 'Hindi name for whole cumin seed.'),
  ('coriander_seeds_whole', 'dhania', 'hi', 'India', 'Hindi name for coriander seed.'),
  ('fennel_seeds_whole', 'saunf', 'hi', 'India', 'Hindi name for fennel seeds.'),
  ('bay_leaves_indian_tej_patta', 'tej patta', 'hi', 'India', 'Hindi name; from cassia tree, distinct from Mediterranean bay laurel.'),
  ('turmeric_ground', 'haldi', 'hi', 'India', 'Hindi name for turmeric.'),
  ('kasoori_methi_dried_fenugreek_leaves', 'kasuri methi', 'hi', 'India', 'Common alternate transliteration.'),
  ('kasoori_methi_dried_fenugreek_leaves', 'dried fenugreek leaves', 'en', 'global', 'English description.'),
  ('nigella_seeds_kalonji', 'kalonji', 'hi', 'India', 'Hindi name for nigella seeds.'),
  ('nigella_seeds_kalonji', 'black onion seed', 'en', 'common usage', 'Common English mistranslation; not actually onion-related.'),
  ('basmati_rice_aged_long_grain', 'basmati', 'hi', 'India', 'Hindi name; refers to fragrant long-grain rice from Indian subcontinent.')
) AS a(canonical_name, alias_name, language, region_origin, notes)
JOIN ingredients ing ON ing.canonical_name = a.canonical_name;

-- ============================================================
-- DISHES (2 new rows)
-- ============================================================

INSERT INTO dishes (id, name, cuisine_id, archetype_id, description, complexity_tier, provenance)
SELECT gen_random_uuid(), d.name, c.id, NULL, d.description, d.complexity::complexity_tier, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Chicken tikka masala (British-Indian style)',
   'British-Indian chicken tikka masala. Yogurt-spice marinated chicken thigh chunks (tikka), grilled or broiled until charred at edges, finished in creamy tomato sauce (masala) built on caramelized onion and ginger-garlic with garam masala, Kashmiri chili, kasoori methi. Originated Glasgow UK 1970s in Bangladeshi/Pakistani-immigrant restaurants. Closest Indian-traditional cousin is murgh makhani (butter chicken), which uses different sauce composition (less cream, more butter, no sugar) and is its own dish.',
   'intermediate'),
  ('Naan (North Indian, leavened flatbread)',
   'North Indian Punjabi-tradition leavened flatbread. Yogurt-enriched yeast dough, optionally enriched with egg. Stretched by hand into teardrop, traditionally cooked in tandoor at 700-900F for 1-2 minutes. Pizza stone in 550F oven or hot cast iron skillet are real food-truck-feasible alternatives. Plain naan is canonical default; garlic, peshwari, keema, butter naan are dish_variants.',
   'intermediate')
) AS d(name, description, complexity)
JOIN cuisines c ON c.name = 'Indian';

-- ============================================================
-- RECIPES (8 rows: 2 parent + 6 sub-recipes)
-- ============================================================

INSERT INTO recipes (id, dish_id, title, source, source_url, instructions, yield_quantity, yield_unit, complexity_tier, submitted_by_user_id, provenance, validity_window_end_date)
SELECT gen_random_uuid(), d.id, r.title, r.source, NULL, r.instructions, r.yield_qty, r.yield_unit, r.complexity::complexity_tier, NULL, 'llm_inferred_low_confidence'::provenance_type, r.validity_end::date
FROM (VALUES
  ('Chicken tikka masala (British-Indian style, Houston metro April 2026)', 'Engine B v1.2 decomposition', 'Marinate chicken in yogurt-spice marinade 4-24 hours. While chicken marinates, prepare sauce: caramelize onion 15-20 min in butter/ghee, add ginger-garlic 2 min, bloom dry spices 30 sec, add tomato paste 2 min, add passata simmer 15 min, blend smooth, add cream simmer 5 min. Grill or broil marinated chicken 8-10 min for charred edges. Combine chicken with sauce, simmer 5 min. Off heat, stir in crushed kasoori methi. Garnish with cilantro. Serve with naan and basmati rice.', 4, 'plates', 'intermediate', '2026-06-30'),
  ('Yogurt-spice marinade (tikka)', 'Engine B v1.2 decomposition', 'Whisk yogurt smooth. Add ginger-garlic paste, garam masala, Kashmiri chili powder, turmeric, cumin, coriander, salt, lemon juice, mustard or neutral oil. Mix until uniformly colored. Coat chicken thoroughly. Refrigerate covered 4-24 hours.', 200, 'g', 'basic_prep', NULL),
  ('Garam masala (house blend, North Indian)', 'Engine B v1.2 decomposition', 'Toast whole spices in dry pan over medium heat 2-3 min until fragrant. Cool completely on plate. Grind fine in spice grinder or mortar. Store airtight. Use within 2-3 months for peak aromatics.', 30, 'g', 'intermediate', NULL),
  ('Tomato-cream sauce (masala)', 'Engine B v1.2 decomposition', 'Sauté finely chopped onion in butter or ghee 15-20 min until deep golden brown. Add ginger-garlic paste, cook 2 min. Add ground spices, bloom in fat 30 sec. Add tomato paste, cook 2 min. Add tomato passata, simmer 15 min. Blend smooth (immersion or stand blender). Add heavy cream, simmer 5 min over low heat. Off heat, crush kasoori methi between palms and stir in. Adjust salt and sugar.', 1000, 'ml', 'intermediate', NULL),
  ('Tikka chicken (charred grilled)', 'Engine B v1.2 decomposition', 'Preheat broiler or grill to highest setting. Arrange marinated chicken on skewers or sheet pan, single layer. Broil or grill 8-10 min, rotating every 3-4 min for even char. Internal temp 165F. Rest 2 min before combining with sauce.', 500, 'g', 'intermediate', NULL),
  ('Naan (North Indian, plain, Houston metro April 2026)', 'Engine B v1.2 decomposition', 'Make dough: bloom yeast 5 min, combine with dry then wet ingredients, knead 8-10 min smooth, proof 2-3 hours. Divide into 100g balls, rest 15 min. Stretch by hand into teardrop. Bake on pizza stone in 550F oven 2-3 min, broil last 30 sec for char. Or skillet on hot cast iron 60-90 sec per side. Brush with melted butter or ghee at service.', 6, 'naan', 'intermediate', '2026-06-30'),
  ('Naan dough (yogurt-enriched)', 'Engine B v1.2 decomposition', 'Bloom yeast in 100ml warm water with sugar 5 min. Combine flour, salt, baking powder in mixer. Add bloomed yeast, yogurt, egg (optional), oil. Mix shaggy, then knead 8-10 min smooth and elastic. Window pane test passes when dough stretches thin without tearing. Proof in oiled covered bowl 2-3 hours until doubled.', 600, 'g', 'intermediate', NULL),
  ('Naan finishing (butter or ghee, optional toppings)', 'Engine B v1.2 decomposition', 'Brush hot baked naan with melted butter or ghee. Optional: sprinkle minced garlic and chopped cilantro for garlic naan variant; nigella seeds for traditional plain naan.', 60, 'g', 'basic_prep', NULL)
) AS r(title, source, instructions, yield_qty, yield_unit, complexity, validity_end)
LEFT JOIN dishes d ON
  (d.name = 'Chicken tikka masala (British-Indian style)' AND r.title LIKE 'Chicken tikka masala%')
  OR (d.name = 'Naan (North Indian, leavened flatbread)' AND r.title LIKE 'Naan (North Indian%');

-- ============================================================
-- RECIPE_INGREDIENTS
-- ============================================================

-- Yogurt-spice marinade
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('yogurt_whole_milk_full_fat', 150::numeric, 'g', NULL::text, 'emulsifier', false, 'Indian dahi or full-fat Greek yogurt.'::text),
  ('garlic_minced', 15, 'g', 'minced or pasted', 'aromatic_base', false, 'Equal parts with ginger as adrak-lehsun paste.'),
  ('ginger_fresh_pasted', 15, 'g', 'minced or pasted', 'aromatic_base', false, NULL),
  ('garam_masala_house_blend', 5, 'g', 'ground', 'spice_accent', false, 'Or pre-made garam masala (real_substitution).'),
  ('kashmiri_chili_powder', 5, 'g', NULL, 'heat_component', false, 'Provides red color WITHOUT extreme heat.'),
  ('turmeric_ground', 2, 'g', NULL, 'spice_base', false, NULL),
  ('cumin_ground', 3, 'g', NULL, 'spice_base', false, NULL),
  ('coriander_ground', 3, 'g', NULL, 'spice_base', false, NULL),
  ('fine_sea_salt', 5, 'g', NULL, 'salt_seasoning', false, NULL),
  ('lemon_juice_fresh', 15, 'ml', 'fresh squeezed', 'acid', true, 'Optional traditional addition; aids tenderization.'),
  ('mustard_oil_indian', 15, 'ml', 'or neutral oil', 'fat_for_cooking', false, 'Mustard oil traditional Punjabi; neutral oil acceptable.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Yogurt-spice marinade (tikka)';

-- Garam masala
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('green_cardamom_pods', 3::numeric, 'g', 'whole, lightly crushed'::text, 'spice_accent', false, NULL::text),
  ('black_cardamom_pods', 1, 'g', 'whole, lightly crushed', 'spice_accent', false, 'Smoky-camphor; distinct from green.'),
  ('cinnamon_stick_true_ceylon', 2, 'g', 'broken into pieces', 'spice_accent', false, 'True Ceylon preferred over cassia.'),
  ('cloves_whole', 1, 'g', 'whole', 'spice_accent', false, NULL),
  ('peppercorns_black_whole', 2, 'g', 'whole', 'heat_component', false, NULL),
  ('cumin_seeds_whole_indian', 5, 'g', 'whole', 'spice_base', false, NULL),
  ('coriander_seeds_whole', 8, 'g', 'whole', 'spice_base', false, NULL),
  ('fennel_seeds_whole', 1, 'g', 'whole', 'spice_accent', true, 'Optional; common in Punjabi blends.'),
  ('bay_leaves_indian_tej_patta', 1, 'g', '2 leaves', 'aromatic_base', false, 'Indian bay (tej patta), distinct from Mediterranean.'),
  ('mace_blade', 0.5, 'g', 'whole blades', 'spice_accent', true, 'Optional; nuanced floral note.'),
  ('nutmeg_whole_for_grating', 0.5, 'g', 'freshly grated', 'spice_accent', true, 'Optional.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Garam masala (house blend, North Indian)';

-- Tomato-cream sauce
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('onion_yellow_finely_chopped', 200::numeric, 'g', 'finely chopped'::text, 'aromatic_base', false, NULL::text),
  ('garlic_minced', 15, 'g', 'minced', 'aromatic_base', false, NULL),
  ('ginger_fresh_pasted', 10, 'g', 'minced', 'aromatic_base', false, NULL),
  ('tomato_passata_or_crushed_canned', 400, 'g', NULL, 'vegetable_substance', false, 'Passata smoother; whole peeled crushed by hand acceptable.'),
  ('tomato_paste_concentrated', 30, 'g', NULL, 'umami_base', false, 'Deepens tomato flavor.'),
  ('heavy_cream_35_to_40_percent', 120, 'ml', NULL, 'structural_fat', false, '35-40% fat; lower-fat creams break in simmer.'),
  ('butter_unsalted', 30, 'g', 'or ghee', 'flavor_fat', false, 'Ghee more traditional. Reused from cheeseburger seed.'),
  ('garam_masala_house_blend', 3, 'g', 'ground', 'spice_accent', false, NULL),
  ('kashmiri_chili_powder', 3, 'g', NULL, 'heat_component', false, NULL),
  ('turmeric_ground', 1, 'g', NULL, 'spice_base', false, NULL),
  ('cumin_ground', 2, 'g', NULL, 'spice_base', false, NULL),
  ('coriander_ground', 2, 'g', NULL, 'spice_base', false, NULL),
  ('sugar_white_granulated', 5, 'g', NULL, 'sweetener', false, 'Balances tomato acidity; British-Indian style.'),
  ('fine_sea_salt', 4, 'g', NULL, 'salt_seasoning', false, NULL),
  ('kasoori_methi_dried_fenugreek_leaves', 2, 'g', 'crushed between palms', 'aromatic_finishing', false, 'CRITICAL ingredient. Added off-heat. Skipping is anti_pattern.'),
  ('cilantro_fresh_sprigs', 10, 'g', 'chopped', 'aromatic_finishing', false, 'Garnish.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Tomato-cream sauce (masala)';

-- Tikka chicken
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, false, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('chicken_thigh_boneless_skinless_for_tikka', 500::numeric, 'g', 'cut into 1.5-inch chunks'::text, 'primary_protein', 'Boneless thigh canonical for CTM; bone-in is more traditional but slower.'::text)
) AS ri(ingredient_canonical, qty, unit, prep, role_name, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Tikka chicken (charred grilled)';

-- Naan dough
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('flour_bread_high_protein', 400::numeric, 'g', NULL::text, 'dough_structure', false, 'Or AP flour with longer kneading.'::text),
  ('yogurt_whole_milk_full_fat', 100, 'g', NULL, 'emulsifier', false, 'Tenderizing and tang.'),
  ('water', 100, 'ml', 'warm, 105-110F', 'cooking_liquid', false, NULL),
  ('yeast_active_dry', 5, 'g', 'bloomed in warm water with sugar', 'leavener', false, NULL),
  ('sugar_white_granulated', 10, 'g', NULL, 'sweetener', false, 'Feeds yeast plus mild sweetness.'),
  ('fine_sea_salt', 8, 'g', NULL, 'salt_seasoning', false, NULL),
  ('eggs_large_aged_7_to_10_days', 1, 'each', 'beaten', 'binder', true, 'Optional traditional addition; richer crumb. Aged egg ingredient reused from tonkotsu seed.'),
  ('neutral_oil_canola_or_grapeseed', 15, 'ml', 'or ghee', 'structural_fat', false, NULL),
  ('baking_powder_aluminum_free', 2, 'g', NULL, 'leavener', true, 'Optional; some recipes use both yeast and baking powder.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Naan dough (yogurt-enriched)';

-- Naan finishing
INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, preparation, role_id, is_optional, notes, inference_source, provenance)
SELECT gen_random_uuid(), r.id, ing.id, ri.qty, ri.unit, ri.prep, role.id, ri.optional, ri.notes, 'llm_parsed'::inference_source, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('butter_unsalted', 5::numeric, 'g', 'melted'::text, 'flavor_fat', false, 'Or ghee, more traditional. Reused from cheeseburger seed.'::text),
  ('garlic_minced', 1, 'g', 'finely minced', 'aromatic_finishing', true, 'For garlic naan variant.'),
  ('cilantro_fresh_sprigs', 1, 'g', 'chopped', 'aromatic_finishing', true, 'Optional garnish.'),
  ('nigella_seeds_kalonji', 0.5, 'g', 'sprinkled', 'aromatic_finishing', true, 'Traditional plain naan sprinkle.')
) AS ri(ingredient_canonical, qty, unit, prep, role_name, optional, notes)
CROSS JOIN recipes r
JOIN ingredients ing ON ing.canonical_name = ri.ingredient_canonical
JOIN ingredient_roles role ON role.name = ri.role_name
WHERE r.title = 'Naan finishing (butter or ghee, optional toppings)';

-- ============================================================
-- RECIPE_SUB_RECIPES
-- ============================================================

INSERT INTO recipe_sub_recipes (id, parent_recipe_id, sub_recipe_id, role_id, quantity, unit, step_order, is_optional, notes, provenance)
SELECT gen_random_uuid(), parent.id, child.id, role.id, link.qty, link.unit, link.step_order, false, link.notes, 'llm_inferred_low_confidence'::provenance_type
FROM (VALUES
  ('Chicken tikka masala (British-Indian style, Houston metro April 2026)', 'Yogurt-spice marinade (tikka)', 'flavor_liquid', 200::numeric, 'g', 1, 'Applied 4-24 hours before cook.'::text),
  ('Chicken tikka masala (British-Indian style, Houston metro April 2026)', 'Garam masala (house blend, North Indian)', 'spice_accent', 8, 'g', 2, 'Used in marinade and sauce.'),
  ('Chicken tikka masala (British-Indian style, Houston metro April 2026)', 'Tomato-cream sauce (masala)', 'sauce_body', 1000, 'ml', 3, 'Built while chicken marinates.'),
  ('Chicken tikka masala (British-Indian style, Houston metro April 2026)', 'Tikka chicken (charred grilled)', 'primary_protein', 500, 'g', 4, 'Grilled separately, integrated into sauce.'),
  ('Naan (North Indian, plain, Houston metro April 2026)', 'Naan dough (yogurt-enriched)', 'dough_structure', 600, 'g', 1, 'Proofed 2-3 hours before shaping and baking.'),
  ('Naan (North Indian, plain, Houston metro April 2026)', 'Naan finishing (butter or ghee, optional toppings)', 'condiment_component', 60, 'g', 2, 'Applied after baking, at service.')
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
  ('Chicken tikka masala (British-Indian style, Houston metro April 2026)', 'simmer_in_sauce_after_grill_or_broil', 1, 'Top-level technique.'::text),
  ('Yogurt-spice marinade (tikka)', 'mince_or_paste_ginger_garlic', 1, NULL),
  ('Yogurt-spice marinade (tikka)', 'whisk_yogurt_smooth', 2, NULL),
  ('Yogurt-spice marinade (tikka)', 'combine_marinade_ingredients_until_uniform', 3, NULL),
  ('Yogurt-spice marinade (tikka)', 'coat_chicken_thoroughly_marinate_4_to_24_hours', 4, NULL),
  ('Garam masala (house blend, North Indian)', 'toast_whole_spices_dry_pan_until_fragrant', 1, NULL),
  ('Garam masala (house blend, North Indian)', 'cool_spices_completely_before_grinding', 2, NULL),
  ('Garam masala (house blend, North Indian)', 'grind_to_fine_powder_in_spice_grinder', 3, NULL),
  ('Tomato-cream sauce (masala)', 'saute_onion_in_butter_or_ghee_until_golden_15_to_20min', 1, 'Dish-defining; do not rush.'),
  ('Tomato-cream sauce (masala)', 'add_garlic_ginger_cook_2min', 2, NULL),
  ('Tomato-cream sauce (masala)', 'add_dry_spices_bloom_in_fat_30sec', 3, NULL),
  ('Tomato-cream sauce (masala)', 'add_tomato_paste_cook_2min', 4, NULL),
  ('Tomato-cream sauce (masala)', 'add_passata_simmer_15min', 5, NULL),
  ('Tomato-cream sauce (masala)', 'blend_sauce_smooth_or_leave_chunky_per_style', 6, 'British-Indian style typically blended smooth.'),
  ('Tomato-cream sauce (masala)', 'add_cream_simmer_5min', 7, NULL),
  ('Tomato-cream sauce (masala)', 'finish_with_kasoori_methi_off_heat', 8, 'Critical step.'),
  ('Tikka chicken (charred grilled)', 'preheat_broiler_or_grill_to_high', 1, NULL),
  ('Tikka chicken (charred grilled)', 'arrange_marinated_chicken_on_skewers_or_sheet_pan', 2, NULL),
  ('Tikka chicken (charred grilled)', 'broil_or_grill_until_charred_edges_8_to_10min', 3, 'Char defines tikka.'),
  ('Tikka chicken (charred grilled)', 'rest_briefly_2min', 4, NULL),
  ('Tikka chicken (charred grilled)', 'combine_with_sauce_simmer_5min', 5, NULL),
  ('Naan (North Indian, plain, Houston metro April 2026)', 'bake_in_tandoor_or_high_heat_alternative', 1, 'Pizza stone in 550F oven OR cast iron skillet are food-truck-feasible alternatives.'),
  ('Naan dough (yogurt-enriched)', 'bloom_yeast_in_warm_water_with_sugar_5min', 1, NULL),
  ('Naan dough (yogurt-enriched)', 'combine_dry_then_wet_ingredients_in_stand_mixer_or_by_hand', 2, NULL),
  ('Naan dough (yogurt-enriched)', 'knead_until_smooth_8_to_10min', 3, NULL),
  ('Naan dough (yogurt-enriched)', 'proof_covered_2_to_3_hours_until_doubled', 4, NULL),
  ('Naan dough (yogurt-enriched)', 'divide_into_balls_100g_each', 5, NULL),
  ('Naan dough (yogurt-enriched)', 'rest_balls_15min_before_shaping', 6, NULL),
  ('Naan dough (yogurt-enriched)', 'shape_naan_by_stretching_into_teardrop', 7, 'Hand-stretching preserves air pockets.'),
  ('Naan dough (yogurt-enriched)', 'bake_on_pizza_stone_550F_2_to_3min', 8, 'Default oven method.'),
  ('Naan dough (yogurt-enriched)', 'broil_last_30sec_for_char', 9, NULL),
  ('Naan dough (yogurt-enriched)', 'skillet_naan_60_to_90sec_per_side_in_hot_cast_iron', 10, 'Alternative for food truck.'),
  ('Naan finishing (butter or ghee, optional toppings)', 'brush_with_butter_or_ghee_at_service', 1, NULL),
  ('Naan finishing (butter or ghee, optional toppings)', 'garnish_with_garlic_cilantro_nigella_optional', 2, NULL)
) AS rt(recipe_title, technique_name, step_order, notes)
JOIN recipes r ON r.title = rt.recipe_title
JOIN techniques t ON t.name = rt.technique_name;

-- ============================================================
-- SUBSTITUTIONS (10 real_substitution + 4 anti_pattern = 14 rows)
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
  ('chicken_thigh_boneless_skinless_for_tikka', 'chicken_thigh_bone_in_for_tikka', 'primary_protein', 'Indian',
   'quality_improvement', 'ingredient_swap', 0.90::numeric, 'similar', NULL::text,
   'Increase cook time 30-40%; monitor for moisture; bone-in retains heat differently.',
   'Lose: ease of eating, faster cook time. Gain: deeper flavor from bone, more traditional tandoor result. When appropriate: traditional tikka, table-service. When NOT appropriate: food truck convenience, fast service.',
   'high', 'stable', 'real_substitution'),
  ('chicken_thigh_boneless_skinless_for_tikka', 'chicken_breast_boneless_skinless_for_tikka', 'primary_protein', 'Indian',
   'dietary_restriction', 'ingredient_swap', 0.65, 'similar', NULL,
   'Reduce cook time 25%; brine 30 min in salted yogurt before marinade application.',
   'Lose: thigh juiciness, fat content that handles char without drying. Gain: leaner protein, lower-fat option. When appropriate: customer-requested. When NOT appropriate: claiming "traditional tikka".',
   'high', 'stable', 'real_substitution'),
  ('heavy_cream_35_to_40_percent', 'coconut_cream_full_fat', 'structural_fat', 'Indian',
   'dietary_restriction', 'ingredient_swap', 0.65, 'similar', NULL,
   'Reduce sugar in sauce by 50%; coconut sweetness compensates.',
   'Lose: dairy character that defines British-Indian CTM. Gain: vegan/dairy-free option, coconut sweetness. When appropriate: vegan menu, coconut-curry style. When NOT appropriate: claiming traditional CTM.',
   'high', 'stable', 'real_substitution'),
  ('heavy_cream_35_to_40_percent', 'cashews_raw_for_cream_substitute', 'structural_fat', 'Indian',
   'dietary_restriction', 'ingredient_swap', 0.75, 'more_expensive', NULL,
   'Soak cashews 4 hours in hot water; blend with water until perfectly smooth; use 1:1 ratio.',
   'Lose: dairy character, slight texture difference. Gain: vegan option, very close mouthfeel to dairy cream. When appropriate: vegan menu, dairy-free positioning, premium positioning. When NOT appropriate: cost-conscious operations.',
   'medium', 'stable', 'real_substitution'),
  ('garam_masala_house_blend', 'garam_masala_premade_mdh_or_everest', 'spice_accent', 'Indian',
   'technique_simplification', 'ingredient_swap', 0.80, 'similar', NULL,
   'Store airtight; use within 2-3 months of opening. Pre-ground loses volatile aromatics quickly.',
   'Lose: control over freshness, custom ratios. Gain: huge convenience, batch consistency. When appropriate: high-volume operations, consistent menu. When NOT appropriate: operations positioned on spice freshness.',
   'high', 'stable', 'real_substitution'),
  ('mustard_oil_indian', 'neutral_oil_canola_or_grapeseed', 'fat_for_cooking', 'Indian',
   'availability_swap', 'ingredient_swap', 0.70, 'cheaper', NULL,
   'Minimal technique change; mustard oil typically heated to smoking before use.',
   'Lose: mustard oil pungent character, traditional Punjabi flavor signature. Gain: cleaner flavor that lets spices shine, easier sourcing. When appropriate: most modern Indian-American restaurants. When NOT appropriate: traditional Punjabi positioning.',
   'low', 'stable', 'real_substitution'),
  ('flour_bread_high_protein', 'flour_all_purpose', 'dough_structure', 'Indian',
   'cost_reduction', 'ingredient_swap', 0.85, 'cheaper', NULL,
   'Knead 2-3 min longer to develop AP flour gluten.',
   'Lose: chewy texture from bread flour gluten development. Gain: softer texture, common pantry ingredient. When appropriate: home cook, common ingredient. When NOT appropriate: artisan naan positioning.',
   'low', 'stable', 'real_substitution'),
  ('flour_bread_high_protein', 'flour_bread_high_protein', 'dough_structure', 'Indian',
   'technique_simplification', 'technique_swap', 0.75, 'cheaper', NULL,
   'Preheat stone fully (45 min minimum); broil last 30 sec for char on top.',
   'Lose: tandoor charcoal smoke character, vertical cooking that produces tandoor-distinctive bottom crust. Gain: feasibility for any kitchen, no tandoor infrastructure. When appropriate: food truck, home kitchen, restaurant without tandoor. When NOT appropriate: traditional tandoor positioning.',
   'high', 'stable', 'real_substitution'),
  ('flour_bread_high_protein', 'flour_bread_high_protein', 'dough_structure', 'Indian',
   'technique_simplification', 'technique_swap', 0.65, 'cheaper', NULL,
   'Preheat skillet very hot 1-2 min; cook 60-90 sec per side; finish with butter.',
   'Lose: more even cook, more char vs pizza stone. Gain: no oven needed; works with any heat source; food truck friendly. When appropriate: food truck operations specifically. When NOT appropriate: when oven available; pizza stone is better.',
   'high', 'stable', 'real_substitution'),
  ('yogurt_whole_milk_full_fat', 'yogurt_whole_milk_full_fat', 'emulsifier', 'Indian',
   'availability_swap', 'ingredient_swap', 0.90, 'similar', NULL,
   'Thin slightly with 15 ml water if too thick.',
   'Lose: nothing meaningful. Gain: Greek yogurt is thicker, clings better to chicken. When appropriate: any operation. When NOT appropriate: when traditional Indian dahi positioning is the menu story.',
   'low', 'stable', 'real_substitution'),
  ('kasoori_methi_dried_fenugreek_leaves', 'kasoori_methi_dried_fenugreek_leaves', 'aromatic_finishing', 'Indian',
   'technique_simplification', 'ingredient_swap', 0.10, 'cheaper', NULL,
   'WARNING: skipping kasoori methi removes the bitter-grassy-maple aroma that defines British-Indian CTM.',
   'ANTI-PATTERN. Most American CTM skips kasoori methi. The result is recognizably less authentic. If unavailable, partial compensation: tiny pinch of celery seed plus touch of maple syrup approximates the profile (still imperfect). In Houston, kasoori methi is abundant at Patel Brothers and House of Spices; this is no excuse to skip.',
   'high', 'stable', 'anti_pattern'),
  ('garam_masala_house_blend', 'garam_masala_house_blend', 'spice_accent', 'Indian',
   'technique_simplification', 'ingredient_swap', 0.30, 'cheaper', NULL,
   'WARNING (boundary anti-pattern): pre-ground spices on the shelf 6+ months have lost most volatile aromatics.',
   'ANTI-PATTERN (boundary). The sauce becomes flat. If using pre-ground, buy small quantities and replace every 3 months. Better: toast whole spices and grind fresh. Quality erosion warning more than hard anti-pattern; flagged for awareness.',
   'medium', 'stable', 'anti_pattern'),
  ('onion_yellow_finely_chopped', 'onion_yellow_finely_chopped', 'aromatic_base', 'Indian',
   'technique_simplification', 'technique_swap', 0.15, 'cheaper', NULL,
   'WARNING: rushing the onion sauté creates a thin, raw-tasting sauce.',
   'ANTI-PATTERN. Onions need 15-20 min to deep caramelize and contribute their full sweetness and umami. Most American home cooks rush this. Result is the "watery curry" failure mode. The 15-20 min is dish-defining time.',
   'high', 'stable', 'anti_pattern'),
  ('chicken_thigh_boneless_skinless_for_tikka', 'chicken_thigh_boneless_skinless_for_tikka', 'primary_protein', 'Indian',
   'technique_simplification', 'technique_swap', 0.05, 'similar', NULL,
   'WARNING: boiling chicken eliminates the tikka char that defines the dish.',
   'ANTI-PATTERN. Chicken tikka is named for the tikka cooking method (tandoor or grilled char). Boiling produces poached chicken with no Maillard, no tikka character. Most common Indian-restaurant shortcut in low-quality American operations. Result is "chicken in masala sauce", not chicken tikka masala. Dish identity destroyed.',
   'high', 'stable', 'anti_pattern')
) AS s(orig_canonical, sub_canonical, role_name, cuisine_name, purpose, kind, quality_score, cost_dir, alt_tech_name, technique_notes, tradeoff_notes, regional, seasonal, classif)
JOIN ingredients orig ON orig.canonical_name = s.orig_canonical
JOIN ingredients sub ON sub.canonical_name = s.sub_canonical
JOIN ingredient_roles role ON role.name = s.role_name
JOIN cuisines cuis ON cuis.name = s.cuisine_name
LEFT JOIN techniques alt_tech ON alt_tech.name = s.alt_tech_name;

COMMIT;
