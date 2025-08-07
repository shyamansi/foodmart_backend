class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # This should prevent your JWT middleware or other custom logic from blocking the OAuth callback
  skip_before_action :authenticate_request, only: [:google_oauth2,:failure]

  def google_oauth2
    auth = request.env['omniauth.auth']
    Rails.logger.debug "Received OmniAuth data: #{auth.inspect}"

    if auth.nil?
      Rails.logger.error "OmniAuth data missing. Redirecting to root."
      redirect_to root_path, alert: "Authentication failed. No data received."
      return
    end

    user = User.find_or_create_by(email: auth.info.email) do |u|
      u.name = auth.info.name
      u.password = Devise.friendly_token[0, 20] # Required if you're using Devise DB auth too
    end

    if user.persisted?
      # Set your own JWT token here if needed
      token = JwtService.encode(user_id: user.id) # assuming you have a JwtService
      Rails.logger.info "Generated token for user #{user.email}: #{token}"

      redirect_to "http://localhost:3001/oauth_success?token=#{token}&email=#{user.email}"
    else
      Rails.logger.error "User couldn't be persisted: #{user.errors.full_messages}"
      redirect_to root_path, alert: "Failed to login via Google."
    end
  end

  def failure
    Rails.logger.error "Omniauth Failure: #{params[:message]}"
    redirect_to root_path, alert: "Authentication failed: #{params[:message]}"
  end
end
