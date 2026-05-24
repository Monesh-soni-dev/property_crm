class ConstructionEstimateMailer < ApplicationMailer
  def estimate_report
    @construction_estimate = params[:construction_estimate]
    attachments["construction-estimate-#{@construction_estimate.id}.pdf"] = {
      mime_type: 'application/pdf',
      content: @construction_estimate.report_pdf.download
    }

    mail(to: params[:email_to], subject: "Construction estimate ##{@construction_estimate.id}")
  end
end