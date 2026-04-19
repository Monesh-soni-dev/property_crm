Rails.application.config.after_initialize do
  ActiveStorage::Current.url_options = Rails.application.config.active_storage.url_options
end