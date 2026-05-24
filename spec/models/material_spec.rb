require 'rails_helper'

RSpec.describe Material, type: :model do
  it 'is valid for construction site inventory' do
    expect(build(:material)).to be_valid
  end

  it 'is valid for estimate catalog entries with a category and specification' do
    expect(build(:material, :catalog_item)).to be_valid
  end

  it 'requires specification for estimate catalog entries' do
    material = build(:material, :catalog_item, specification: nil)

    expect(material).not_to be_valid
    expect(material.errors[:specification]).to be_present
  end
end
