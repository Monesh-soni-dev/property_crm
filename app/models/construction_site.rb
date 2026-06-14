class ConstructionSite < ApplicationRecord
  belongs_to :project
  has_many :milestones, dependent: :destroy
  has_many :workers, dependent: :destroy
  has_many :materials, dependent: :destroy
  has_many :site_documents, dependent: :destroy

  before_create :generate_share_token

  STATUSES = %w[planning foundation structure brickwork roofing finishing completed].freeze

  def generate_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(16)
  end

  def computed_progress
    return overall_progress if overall_progress.present?
    return 0 if milestones.empty?

    milestones.average(:completion_pct).to_i
  end

  def timeline_phases
    milestones.order(:planned_date).map do |ms|
      {
        id:          ms.id,
        title:       ms.title,
        description: ms.description,
        planned:     ms.planned_date,
        actual:      ms.actual_date,
        status:      ms.status,
        pct:         ms.completion_pct.to_i,
        tasks_total: ms.construction_tasks.count,
        tasks_done:  ms.construction_tasks.where(status: 'completed').count,
        docs:        ms.site_documents.count
      }
    end
  end

  def days_remaining
    return nil unless expected_completion
    (expected_completion - Date.today).to_i
  end

  def on_schedule?
    return true unless expected_completion && start_date
    total_days   = (expected_completion - start_date).to_f
    elapsed_days = (Date.today - start_date).to_f
    expected_pct = (elapsed_days / total_days * 100).clamp(0, 100)
    computed_progress >= expected_pct - 10
  end
end
