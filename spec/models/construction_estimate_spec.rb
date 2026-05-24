require 'rails_helper'

RSpec.describe ConstructionEstimate, type: :model do
  subject(:estimate) { build(:construction_estimate) }

  it 'calculates plot area before validation' do
    estimate.valid?

    expect(estimate.plot_area.to_f).to eq(1200.0)
  end

  it 'rejects construction area above the city FAR limit' do
    estimate.construction_area = 3000

    expect(estimate).not_to be_valid
    expect(estimate.errors[:construction_area]).to be_present
  end

  it 'rejects floor count above the city limit' do
    estimate.number_of_floors = 8

    expect(estimate).not_to be_valid
    expect(estimate.errors[:number_of_floors]).to be_present
  end
end