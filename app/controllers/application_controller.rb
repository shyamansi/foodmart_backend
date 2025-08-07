class ApplicationController < ActionController::API
    #  before_action :debug_auth!
         before_action :authenticate_request
          attr_reader :current_user
def preflight
  head :ok
end
  def debug_auth!
    Rails.logger.debug "Auth Header: #{request.headers['Authorization'].to_s.split(' ').last}"
    Rails.logger.debug "Current User before authenticate_user!: #{current_user.inspect}"
    authenticate_user!
    Rails.logger.debug "Current User after authenticate_user!: #{current_user.inspect}"
  end

   def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last
    Rails.logger.debug "Authorization Header: #{header}"
    Rails.logger.debug "Token: #{token}"
    Rails.logger.debug "Current User before decoding token: #{@current_user.inspect}" if @current

    if token
      begin
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        @current_user = User.find(decoded['sub'])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Invalid or expired token' }, status: :unauthorized
      end
    else
      render json: { error: 'Token missing' }, status: :unauthorized
    end
  end
end
