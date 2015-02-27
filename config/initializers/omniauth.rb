Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oauth2, ENV['DOORKEEPER_APP_ID'], ENV['DOORKEEPER_APP_SECRET']
end
