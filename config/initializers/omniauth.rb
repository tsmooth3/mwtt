# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials.oauth[:google_client_id], Rails.application.credentials.oauth[:google_client_secret]
end

OmniAuth.config.allowed_request_methods = [ :post, :get ]
