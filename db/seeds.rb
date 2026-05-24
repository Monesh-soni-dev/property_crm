# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

material_categories = [
	{ name: 'Cement', display_order: 1 },
	{ name: 'Steel', display_order: 2 },
	{ name: 'Masonry', display_order: 3 },
	{ name: 'Aggregates', display_order: 4 },
	{ name: 'Finishing', display_order: 5 },
	{ name: 'Services', display_order: 6 }
]

categories = material_categories.index_with do |attributes|
	MaterialCategory.find_or_create_by!(name: attributes[:name]) do |category|
		category.display_order = attributes[:display_order]
	end
end

materials = [
	{ name: 'Portland Cement', category: 'Cement', unit: 'bag', specification: '43 Grade, 50kg bag' },
	{ name: 'TMT Steel Bars', category: 'Steel', unit: 'kg', specification: 'Fe 500, corrosion resistant' },
	{ name: 'Red Clay Bricks', category: 'Masonry', unit: 'brick', specification: '9 inch kiln-fired brick' },
	{ name: 'River Sand', category: 'Aggregates', unit: 'cft', specification: 'Washed M-sand equivalent' },
	{ name: '20mm Aggregate', category: 'Aggregates', unit: 'cft', specification: 'Machine-crushed aggregate' },
	{ name: 'Vitrified Tiles', category: 'Finishing', unit: 'sqft', specification: '2x2 premium vitrified tile' },
	{ name: 'Interior Emulsion Paint', category: 'Finishing', unit: 'liter', specification: 'Interior acrylic emulsion, 2 coats' },
	{ name: 'Electrical Works', category: 'Services', unit: 'sqft', specification: 'Wiring, switches, DB and fixtures allowance' },
	{ name: 'Plumbing Works', category: 'Services', unit: 'sqft', specification: 'Internal water lines, drainage and fixtures allowance' }
]

catalog = materials.index_with do |attributes|
	Material.find_or_create_by!(name: attributes[:name], construction_site_id: nil) do |material|
		material.material_category = categories.fetch(attributes[:category])
		material.unit = attributes[:unit]
		material.specification = attributes[:specification]
	end
end

city_multipliers = {
	'Bangalore' => 1.0,
	'Mumbai' => 1.22,
	'Delhi' => 1.08,
	'Chennai' => 1.03,
	'Hyderabad' => 0.98
}

base_basic_prices = {
	'Portland Cement' => 350,
	'TMT Steel Bars' => 55,
	'Red Clay Bricks' => 8,
	'River Sand' => 60,
	'20mm Aggregate' => 75,
	'Vitrified Tiles' => 45,
	'Interior Emulsion Paint' => 320,
	'Electrical Works' => 140,
	'Plumbing Works' => 110
}

tier_multipliers = {
	'basic' => 1.0,
	'standard' => 1.15,
	'premium' => 1.35
}

city_multipliers.each do |city, city_multiplier|
	base_basic_prices.each do |material_name, base_price|
		tier_multipliers.each do |quality_tier, tier_multiplier|
			MaterialPrice.find_or_initialize_by(
				material: catalog.fetch(material_name),
				city: city,
				quality_tier: quality_tier,
				effective_from: Date.current.beginning_of_year
			).tap do |price|
				price.price_per_unit = (base_price * city_multiplier * tier_multiplier).round(2)
				price.is_active = true
				price.save!
			end
		end
	end
end

puts 'Seeded construction estimate material catalog and city pricing.'
