# Construction Cost Estimation - Seed Data
# Run with: rails db:seed or rails runner db/seeds/construction_materials.rb

puts "Seeding construction material categories, materials, and prices..."

# ─── Categories ─────────────────────────────────────────────
categories_data = [
  { name: "Cement",      display_order: 1 },
  { name: "Steel",       display_order: 2 },
  { name: "Bricks",      display_order: 3 },
  { name: "Sand",        display_order: 4 },
  { name: "Aggregate",   display_order: 5 },
  { name: "Tiles",       display_order: 6 },
  { name: "Paint",       display_order: 7 },
  { name: "Electrical",  display_order: 8 },
  { name: "Plumbing",    display_order: 9 }
]

categories = {}
categories_data.each do |cat|
  categories[cat[:name]] = MaterialCategory.find_or_create_by!(name: cat[:name]) do |c|
    c.display_order = cat[:display_order]
  end
end

# ─── Materials ──────────────────────────────────────────────
materials_data = {
  "Cement" => [
    { name: "Portland Cement (43 Grade)", unit: "bag", specification: "43 Grade, 50kg bag" },
    { name: "Portland Cement (53 Grade)", unit: "bag", specification: "53 Grade, 50kg bag" }
  ],
  "Steel" => [
    { name: "TMT Bars (Fe 500)",  unit: "kg", specification: "Fe 500 grade, 8mm-25mm" },
    { name: "TMT Bars (Fe 500D)", unit: "kg", specification: "Fe 500D grade, earthquake resistant" }
  ],
  "Bricks" => [
    { name: "Red Clay Bricks",    unit: "brick", specification: "Standard size 9×4.5×3 inches" },
    { name: "Fly Ash Bricks",     unit: "brick", specification: "Standard size, lightweight" },
    { name: "AAC Blocks",         unit: "block", specification: "Autoclaved Aerated Concrete, 600×200×200mm" }
  ],
  "Sand" => [
    { name: "River Sand (M-Sand)", unit: "cft", specification: "Manufactured sand, Zone II" },
    { name: "Plastering Sand",     unit: "cft", specification: "Fine grade for plastering" }
  ],
  "Aggregate" => [
    { name: "Coarse Aggregate (20mm)", unit: "cft", specification: "Crushed stone 20mm graded" },
    { name: "Coarse Aggregate (12mm)", unit: "cft", specification: "Crushed stone 12mm graded" }
  ],
  "Tiles" => [
    { name: "Ceramic Floor Tiles",    unit: "sqft", specification: "600×600mm, matt finish" },
    { name: "Vitrified Floor Tiles",  unit: "sqft", specification: "800×800mm, glossy finish" }
  ],
  "Paint" => [
    { name: "Interior Emulsion Paint", unit: "litre", specification: "Acrylic emulsion, washable" },
    { name: "Exterior Weather Coat",   unit: "litre", specification: "Weather-proof exterior paint" }
  ],
  "Electrical" => [
    { name: "Electrical Wiring & Fittings", unit: "sqft", specification: "Complete wiring, switches, sockets per sqft" }
  ],
  "Plumbing" => [
    { name: "Plumbing & Sanitary Fittings", unit: "sqft", specification: "Complete plumbing, pipes, fittings per sqft" }
  ]
}

materials = {}
materials_data.each do |cat_name, mats|
  category = categories[cat_name]
  mats.each do |mat|
    m = ConstructionMaterial.find_or_create_by!(
      material_category: category,
      name: mat[:name]
    ) do |cm|
      cm.unit = mat[:unit]
      cm.specification = mat[:specification]
    end
    materials[mat[:name]] = m
  end
end

# ─── Prices by city and tier ────────────────────────────────
cities = %w[Bangalore Mumbai Delhi Chennai Hyderabad Pune Kolkata Ahmedabad]

# Base prices (Bangalore, basic tier)
base_prices = {
  "Portland Cement (43 Grade)"      => 350,
  "Portland Cement (53 Grade)"      => 400,
  "TMT Bars (Fe 500)"               => 55,
  "TMT Bars (Fe 500D)"              => 62,
  "Red Clay Bricks"                 => 8,
  "Fly Ash Bricks"                  => 6,
  "AAC Blocks"                      => 55,
  "River Sand (M-Sand)"             => 35,
  "Plastering Sand"                 => 40,
  "Coarse Aggregate (20mm)"         => 28,
  "Coarse Aggregate (12mm)"         => 30,
  "Ceramic Floor Tiles"             => 35,
  "Vitrified Floor Tiles"           => 55,
  "Interior Emulsion Paint"         => 180,
  "Exterior Weather Coat"           => 250,
  "Electrical Wiring & Fittings"    => 80,
  "Plumbing & Sanitary Fittings"    => 60
}

# City multipliers relative to Bangalore
city_multipliers = {
  "Bangalore"  => 1.00,
  "Mumbai"     => 1.25,
  "Delhi"      => 1.15,
  "Chennai"    => 1.05,
  "Hyderabad"  => 0.95,
  "Pune"       => 1.10,
  "Kolkata"    => 0.90,
  "Ahmedabad"  => 0.92
}

# Quality tier multipliers
tier_multipliers = {
  "basic"    => 1.00,
  "standard" => 1.30,
  "premium"  => 1.75
}

effective_date = Date.new(2026, 1, 1)

cities.each do |city|
  tier_multipliers.each do |tier, tier_mult|
    base_prices.each do |mat_name, base_price|
      material = materials[mat_name]
      next unless material

      price = (base_price * city_multipliers[city] * tier_mult).round(2)

      MaterialPrice.find_or_create_by!(
        construction_material: material,
        city: city,
        quality_tier: tier,
        effective_from: effective_date
      ) do |mp|
        mp.price_per_unit = price
        mp.is_active = true
      end
    end
  end
end

puts "Seeded #{MaterialCategory.count} categories, #{ConstructionMaterial.count} materials, #{MaterialPrice.count} prices."
