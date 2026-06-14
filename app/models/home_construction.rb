class HomeConstruction < ApplicationRecord
  belongs_to :user
  has_many :construction_phases, -> { order(:phase_order) }, dependent: :destroy

  before_create :generate_share_token

  STATUSES = %w[planning in_progress on_hold completed].freeze

  DEFAULT_PHASES = [
    { name: "Site Preparation",              order: 1  },
    { name: "Foundation Work",               order: 2  },
    { name: "Plinth & DPC",                  order: 3  },
    { name: "Structural Framework",          order: 4  },
    { name: "Brick / Block Work",            order: 5  },
    { name: "Roofing Slab",                  order: 6  },
    { name: "Waterproofing & Plumbing (Rough-in)", order: 7 },
    { name: "Electrical Works (Rough-in)",   order: 8  },
    { name: "Plastering",                    order: 9  },
    { name: "Flooring",                      order: 10 },
    { name: "Doors & Windows Fitting",       order: 11 },
    { name: "Painting & Finishing",          order: 12 },
    { name: "Electrical & Plumbing (Fixtures)", order: 13 },
    { name: "Final Inspection & Handover",   order: 14 }
  ].freeze

  validates :name,   presence: true, length: { maximum: 120 }
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  validates :address,       length: { maximum: 255 }, allow_blank: true
  validates :city,          length: { maximum: 100 }, allow_blank: true
  validates :site_manager,  length: { maximum: 100 }, allow_blank: true

  validates :site_manager_phone,
            format: { with: /\A(\+91)?[0-9]{10}\z/, message: "must be 10 digits or +91 followed by 10 digits" },
            allow_blank: true

  validates :client_name,   length: { maximum: 120 }, allow_blank: true
  validates :client_phone,
            format: { with: /\A(\+91)?[0-9]{10}\z/, message: "must be 10 digits or +91 followed by 10 digits" },
            allow_blank: true
  validates :client_email,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
            allow_blank: true

  validates :total_built_area,
            numericality: { greater_than: 0, message: "must be greater than 0" },
            allow_blank: true
  validates :number_of_floors,
            numericality: { only_integer: true, greater_than: 0, message: "must be a whole number greater than 0" },
            allow_blank: true

  validate :completion_after_start

  validates :description,    length: { maximum: 1000 }, allow_blank: true
  validates :customer_notes, length: { maximum: 1000 }, allow_blank: true

  def overall_progress
    return 0 if construction_phases.empty?
    construction_phases.average(:completion_pct).to_i
  end

  def days_remaining
    return nil unless expected_completion
    (expected_completion - Date.today).to_i
  end

  def on_schedule?
    return true unless expected_completion && start_date
    total = (expected_completion - start_date).to_f
    return true if total <= 0
    elapsed  = (Date.today - start_date).to_f
    expected = (elapsed / total * 100).clamp(0, 100)
    overall_progress >= expected - 10
  end

  def current_phase
    construction_phases.where(status: 'in_progress').order(:phase_order).first ||
      construction_phases.where.not(status: 'completed').order(:phase_order).first
  end

  def build_default_phases!
    return if construction_phases.any?
    DEFAULT_PHASES.each do |p|
      construction_phases.create!(
        name:         p[:name],
        phase_order:  p[:order],
        status:       'pending',
        completion_pct: 0
      )
    end
  end

  private

  def generate_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(16)
  end

  def completion_after_start
    return unless start_date.present? && expected_completion.present?
    if expected_completion <= start_date
      errors.add(:expected_completion, "must be after the construction start date")
    end
  end
end
