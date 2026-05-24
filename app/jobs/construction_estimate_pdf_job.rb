class ConstructionEstimatePdfJob < ApplicationJob
  queue_as :default

  def perform(construction_estimate_id, email_to: nil)
    estimate = ConstructionEstimate.find(construction_estimate_id)
    pdf_data = ConstructionEstimatePdfRenderer.new(estimate).render

    estimate.report_pdf.attach(
      io: StringIO.new(pdf_data),
      filename: "construction-estimate-#{estimate.id}.pdf",
      content_type: 'application/pdf'
    )

    return if email_to.blank?

    ConstructionEstimateMailer.with(construction_estimate: estimate, email_to: email_to).estimate_report.deliver_now
  end
end