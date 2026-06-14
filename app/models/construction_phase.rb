class ConstructionPhase < ApplicationRecord
  belongs_to :home_construction

  STATUSES = %w[pending in_progress completed on_hold].freeze

  validates :name,   presence: true
  validates :status, inclusion: { in: STATUSES }, allow_blank: true
  validates :completion_pct, numericality: { in: 0..100 }, allow_nil: true

  before_save :auto_complete_pct

  scope :ordered, -> { order(:phase_order) }

  private

  def auto_complete_pct
    self.completion_pct ||= 0
    if status == 'completed' && completion_pct < 100
      self.completion_pct = 100
      self.actual_end   ||= Date.today
    end
    if status == 'in_progress' && actual_start.nil?
      self.actual_start = Date.today
    end
  end
end
