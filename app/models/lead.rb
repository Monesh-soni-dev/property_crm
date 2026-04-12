class Lead < ApplicationRecord
  belongs_to :project
  belongs_to :property, optional: true
  belongs_to :user
  has_many :activities, dependent: :destroy
  enum stage: { new_lead: 0, contacted: 1, site_visit: 2,negotiation: 3, booked: 4, lost: 5 }
  after_update :sync_property_status   # blocks property when lead is booked

end

