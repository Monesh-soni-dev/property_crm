require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "nested properties" do
    it "creates multiple properties with the project" do
      user = create(:user, role: :builder)

      project = described_class.create!(
        user: user,
        name: "Skyline Residency",
        properties_attributes: [
          { user: user, title: "Tower A - 2BHK", unit_number: "A-101", status: "available" },
          { user: user, title: "Tower B - 3BHK", unit_number: "B-202", status: "booked" }
        ]
      )

      expect(project.properties.size).to eq(2)
      expect(project.properties.pluck(:unit_number)).to contain_exactly("A-101", "B-202")
    end

    it "ignores blank property blocks" do
      user = create(:user, role: :builder)

      project = described_class.create!(
        user: user,
        name: "Park View",
        properties_attributes: [
          { title: "", unit_number: "", status: "" }
        ]
      )

      expect(project.properties).to be_empty
    end
  end
end
