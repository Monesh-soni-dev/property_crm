class ApplicationMailer < ActionMailer::Base
  default from: ENV["DEFAULT_FROM_EMAIL"].presence || ENV["SMTP_USERNAME"].presence || "no-reply@localhost"
  layout "mailer"
end
