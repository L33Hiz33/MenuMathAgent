-- ============================================================
-- Migration: 0002_role_taxonomy_seed
-- Seeds the 36 canonical ingredient roles for v1.
--
-- These are the SLOTS the substitution engine reasons over.
-- Every recipe_ingredient, dish_ingredient_role, and
-- substitution row references one of these by id.
--
-- Roles were locked through stress-testing against real
-- dishes: gumbo, banh mi, beef Wellington, margherita,
-- turducken, Thai green curry, mole poblano. Catch-all
-- role (other_component) handles edge cases; pattern
-- review (separate migration) surfaces recurring catch-all
-- usage for promotion to real roles.
--
-- Provenance: human_verified_expert (curated taxonomy)
-- Applied: 2026-04-29
-- ============================================================

INSERT INTO ingredient_roles (name, description, provenance) VALUES

-- Proteins
('primary_protein',
 'Headlining protein component giving the dish its identity. Multiple rows allowed when two proteins both headline (surf and turf, turducken outer layers). Examples: chicken in tikka, beef in burger, fish in fish tacos.',
 'human_verified_expert'),

('secondary_protein',
 'Supporting protein adding depth without being the dish identity. Examples: bacon in bean stew, anchovy in pasta sauce, pancetta in carbonara.',
 'human_verified_expert'),

-- Fats
('fat_for_cooking',
 'Cooking medium where smoke point matters. Examples: neutral oil for frying, lard for searing, ghee for high-heat saute.',
 'human_verified_expert'),

('flavor_fat',
 'Fat chosen for flavor; smoke point secondary. Examples: butter in duxelles, schmaltz in matzo ball soup, sesame oil finish, brown butter.',
 'human_verified_expert'),

('structural_fat',
 'Fat doing mechanical work: lamination, emulsion, mouthfeel body. Examples: butter in puff pastry, butter in beurre blanc, cold butter in pie dough, oil in mayonnaise.',
 'human_verified_expert'),

-- Starches and structure
('starch_base',
 'The starch the dish is served on or built around. Examples: rice under gumbo, baguette in banh mi, pizza dough in margherita, naan with curry.',
 'human_verified_expert'),

('thickening_agent',
 'Anything that thickens a sauce or stew, whether by gelatinization, absorption, or emulsion. Examples: flour in roux, cornstarch slurry, ground almonds in mole, ground tortilla in mole, breadcrumbs in soup.',
 'human_verified_expert'),

('dough_structure',
 'Flour or alternative whose gluten network gives a baked good its structure. Examples: 00 flour for pizza, bread flour for baguette, pastry flour for Wellington shell.',
 'human_verified_expert'),

('leavener',
 'Rise agent: biological, chemical, or mechanical. Examples: sourdough culture, instant yeast, baking powder, whipped egg whites.',
 'human_verified_expert'),

-- Liquids
('cooking_liquid',
 'Liquid that cooks the dish or carries heat. Examples: stock in gumbo, court bouillon for poaching, water for pasta.',
 'human_verified_expert'),

('flavor_liquid',
 'Liquid for flavor delivery, not heat transfer. Examples: fish sauce in marinade, soy in glaze, wine in pan sauce, mirin in teriyaki.',
 'human_verified_expert'),

('acid',
 'Acidification for flavor, preservation, or chemistry. Examples: rice vinegar in pickle, lemon juice, tomato acidity, lime in ceviche.',
 'human_verified_expert'),

-- Sauce body
('sauce_body',
 'Liquid or semi-liquid component that gives a sauce its volume, mouthfeel, or richness. The sauce IS the dish (chicken eaten in mole sauce, chicken in green curry). Distinct from cooking_liquid (heat transfer) and structural_fat (mechanical work). Examples: coconut milk in green curry, mole sauce on chicken, cream in cream sauce, yogurt base in some curries, tahini in hummus dressing.',
 'human_verified_expert'),

-- Aromatics and flavor matrix
('aromatic_base',
 'Cooked at the start, foundational savory profile. Examples: holy trinity in gumbo, soffritto in ragu, mirepoix in stock, charred onion and garlic in mole.',
 'human_verified_expert'),

('aromatic_finishing',
 'Added late or raw; volatile compounds. Examples: cilantro on banh mi, basil on margherita, scallion garnish on pho, sesame seed on mole.',
 'human_verified_expert'),

('flavor_paste',
 'Pre-composed flavor matrix delivered as a single sub-recipe component, containing the dish flavor architecture. Examples: Thai green curry paste, mole base, Cuban sofrito, Puerto Rican recaito, Indian masala paste.',
 'human_verified_expert'),

-- Spice and seasoning
('spice_base',
 'Dried spice contributing baseline flavor through sustained cooking. Examples: cayenne in gumbo, black pepper in pate, fennel in Italian sausage, cinnamon stick in mole.',
 'human_verified_expert'),

('spice_accent',
 'Dried spice or blend providing a defining top note, often added late. Examples: file powder on gumbo, sumac on salad, togarashi on ramen, smoked paprika on finished dish.',
 'human_verified_expert'),

('salt_seasoning',
 'Salt or salt-equivalent used throughout cooking. Examples: kosher salt, soy sauce in seasoning role, fish sauce in seasoning role, MSG.',
 'human_verified_expert'),

('salt_finishing',
 'Salt as final crystal at service. Examples: Maldon on steak, fleur de sel on caramel, flaky salt on focaccia.',
 'human_verified_expert'),

-- Umami, heat, sweet, smoke
('umami_base',
 'Deep savory backbone. Examples: soy sauce, fish sauce, miso, parmesan rind, dried mushroom, tomato paste, anchovy, dried chiles in mole (ancho, mulato, pasilla).',
 'human_verified_expert'),

('heat_component',
 'Chili heat or pungency. Examples: fresh chiles, chili paste, mustard, horseradish, chipotle (when used for heat).',
 'human_verified_expert'),

('sweetener',
 'Added sweetness, distinct from naturally-sweet vegetables or fruit. Examples: sugar, honey, maple, palm sugar, piloncillo, Mexican chocolate (when used for balance).',
 'human_verified_expert'),

('smoke_component',
 'Smoked flavor vector. Examples: smoked paprika, chipotle (when used for smoke), liquid smoke, smoked salt, lapsang souchong tea.',
 'human_verified_expert'),

-- Texture, structure, function
('texture_crunch',
 'Primary contribution is crisp or crunchy texture in contrast to softer elements. Examples: fried shallots, peanuts (whole, not ground), croutons, pomegranate seeds, fresh-fried chicharron.',
 'human_verified_expert'),

('binder',
 'Holds something together. Examples: egg in meatballs, breadcrumbs in meatloaf, cornstarch slurry in stir-fry, panade for burgers.',
 'human_verified_expert'),

('emulsifier',
 'Stabilizes a mixture of fat and water. Distinct from binder (general cohesion) and structural_fat (mechanical body). Examples: egg yolk in mayonnaise/aioli/hollandaise, mustard in vinaigrette, lecithin, mustard in beurre blanc.',
 'human_verified_expert'),

('interstitial_layer',
 'Load-bearing layer between proteins or in void space, providing moisture and flavor distribution. Distinct from a side-dish stuffing. Examples: turducken stuffings between protein layers, duxelles in Wellington, pate in banh mi (when functioning as moisture/flavor layer).',
 'human_verified_expert'),

('coating_dry',
 'Dry coating before cooking. Examples: flour dredge for fried chicken, panko for katsu, cornmeal on fish, seasoned flour for schnitzel.',
 'human_verified_expert'),

-- Vegetables
('vegetable_substance',
 'Vegetable providing bulk, body, or main flavor when not aromatic and not the starch base. Examples: eggplant in baba ghanoush, mushroom in risotto, cabbage in slaw, carrots in stew, Thai eggplant in green curry, bamboo shoots.',
 'human_verified_expert'),

-- Composed components
('pickle_component',
 'A pickled element occupying its slot in the parent dish, providing acid, crunch, and brightness counterpoint to rich main components. Examples: banh mi pickled daikon and carrot, German kraut on sausage, Korean banchan, Mexican pickled red onion, Japanese tsukemono, Indian achaar.',
 'human_verified_expert'),

('condiment_component',
 'Composed cold accompaniment served with the dish. Examples: chimichurri, salsa verde, raita, tzatziki, harissa, gremolata.',
 'human_verified_expert'),

('sauce_component',
 'Composed hot or warm sauce served with the dish, distinct from a sauce that IS the dish (use sauce_body for those). Examples: gravy on roast, jus on steak, cream sauce on pasta when ladled separately.',
 'human_verified_expert'),

('dressing_component',
 'Composed cold sauce on salads, grain bowls, or cold dishes. Examples: vinaigrette, ranch, Caesar dressing, tahini dressing.',
 'human_verified_expert'),

('glaze_component',
 'Shiny finishing coat applied during or after cooking. Examples: hoisin lacquer on duck, honey-mustard glaze on ham, miso glaze on fish, balsamic reduction.',
 'human_verified_expert'),

-- Catch-all
('other_component',
 'Use ONLY when no other role fits. Notes field REQUIRED on every usage, describing what the ingredient is doing in the dish. Pattern review surfaces recurring other_component notes for promotion to real roles.',
 'human_verified_expert');

-- ============================================================
-- Verification query (run after the INSERT to confirm):
-- SELECT COUNT(*) AS total_roles FROM ingredient_roles;
-- Expected: 36
-- ============================================================
