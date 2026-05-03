class Lead < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :property, optional: true
  belongs_to :user
  has_many :activities, dependent: :destroy
  
  # Status enum - using stage instead of status for compatibility
  enum stage: { 
    new_lead: 'new_lead',
    contacted: 'contacted', 
    interested: 'interested',
    visit_scheduled: 'visit_scheduled',
    negotiation: 'negotiation',
    closed: 'closed',
    rejected: 'rejected'
  }

  # Validations
  validates :customer_name, presence: true
  validates :customer_phone, presence: true, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }
  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :today_followups, -> { where(follow_up_date: Date.current) }
  scope :by_status, ->(status) { where(stage: status) if status.present? }
  scope :for_user, ->(user) { where(user: user) }
  
  # Search scope - improved for safety
  scope :search, ->(query) {
    return all if query.blank?
    
    sanitized_query = ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)
    where(
      "customer_name ILIKE ? OR customer_phone ILIKE ? OR property_name ILIKE ? OR customer_email ILIKE ?",
      "%#{sanitized_query}%", "%#{sanitized_query}%", "%#{sanitized_query}%", "%#{sanitized_query}%"
    )
  }

  # Backward compatibility methods for old field names
  def name
    customer_name
  end
  
  def name=(value)
    self.customer_name = value
  end
  
  def phone
    customer_phone
  end
  
  def phone=(value)
    self.customer_phone = value
  end
  
  def email
    customer_email
  end
  
  def email=(value)
    self.customer_email = value
  end

  # Dashboard helper methods
  def self.total_leads_for(user)
    where(user: user).count
  end
  
  def self.today_followups_for(user)
    where(user: user, follow_up_date: Date.current).count
  end
  
  def self.closed_leads_for(user)
    where(user: user, stage: 'closed').count
  end
  
  def self.stats_for(user)
    leads = where(user: user)
    {
      total: leads.count,
      today_followups: leads.where(follow_up_date: Date.current).count,
      closed: leads.where(stage: 'closed').count,
      new_lead: leads.where(stage: 'new_lead').count,
      contacted: leads.where(stage: 'contacted').count,
      interested: leads.where(stage: 'interested').count
    }
  end

  after_update :sync_property_status   # blocks property when lead is booked

  private

  def sync_property_status
    return unless property.present?
    
    if stage == 'booked'
      property.update(status: :blocked) if property.available?
    elsif stage_was == 'booked' && stage != 'booked'
      # If lead was booked but no longer is, make property available again
      property.update(status: :available) if property.blocked?
    end
  end
end

