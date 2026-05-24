require 'rails_helper'

RSpec.describe ConstructionCostCalculator do
  describe '#call' do
    let!(:cement_category) { create(:material_category, name: 'Cement') }
    let!(:steel_category) { create(:material_category, name: 'Steel') }
    let!(:masonry_category) { create(:material_category, name: 'Masonry') }
    let!(:aggregates_category) { create(:material_category, name: 'Aggregates') }
    let!(:finishing_category) { create(:material_category, name: 'Finishing') }
    let!(:services_category) { create(:material_category, name: 'Services') }

    before do
      {
        'Portland Cement' => ['bag', cement_category],
        'TMT Steel Bars' => ['kg', steel_category],
        'Red Clay Bricks' => ['brick', masonry_category],
        'River Sand' => ['cft', aggregates_category],
        '20mm Aggregate' => ['cft', aggregates_category],
        'Vitrified Tiles' => ['sqft', finishing_category],
        'Interior Emulsion Paint' => ['liter', finishing_category],
        'Electrical Works' => ['sqft', services_category],
        'Plumbing Works' => ['sqft', services_category]
      }.each do |name, (unit, category)|
        material = create(:material, construction_site: nil, material_category: category, name: name, unit: unit, specification: 'Spec')
        create(:material_price, material: material, city: 'Bangalore', quality_tier: 'standard', price_per_unit: 100)
      end
    end

    it 'returns itemized material and summary costs' do
      result = described_class.new(
        plot_length: 30,
        plot_width: 40,
        city: 'Bangalore',
        quality_tier: 'standard',
        number_of_floors: 2,
        construction_area: 1600
      ).call

      expect(result[:materials].size).to eq(9)
      expect(result.dig(:summary, :grand_total)).to be > result.dig(:summary, :material_subtotal)
      expect(result.dig(:area, :construction_area)).to eq(1600.0)
    end
  end
end