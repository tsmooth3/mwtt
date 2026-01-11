# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  # Only configure Google OAuth if credentials are available
  # This allows asset precompilation to work without credentials during Docker build
  begin
    oauth_creds = Rails.application.credentials.dig(:oauth)
    if oauth_creds && oauth_creds[:google_client_id] && oauth_creds[:google_client_secret]
      provider :google_oauth2, 
               oauth_creds[:google_client_id], 
               oauth_creds[:google_client_secret]
    end
  rescue NoMethodError, TypeError
    # Credentials not available (e.g., during Docker build without master key)
    # OAuth will be unavailable, but app can still run
  end
end

OmniAuth.config.allowed_request_methods = [ :post, :get ]
