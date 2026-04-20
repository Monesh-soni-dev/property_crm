require 'rails_helper'

RSpec.describe Property, type: :model do
  it "defaults status to available" do
    property = build(:property, status: nil)

    expect(property.status).to eq("available")
  end
end
