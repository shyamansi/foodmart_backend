class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_request, only: [:create]
  respond_to :json

  # ✅ Overriding create to remove flash usage
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)

    render json: {
      status: :ok,
      data: {
        code: 200,
        message: "User signed in successfully",
        data: {
          id: resource.id,
          email: resource.email,
          is_admin: resource.is_admin
          # Add more fields if needed
        }
      }
    }, status: :ok
  end

  # ✅ Override to suppress Devise's flash expectation
  def respond_with(resource, _opts = {})
    # No-op since we're fully handling in `create`
  end

  def respond_to_on_destroy
    token = request.headers['Authorization']&.split(' ')&.last

    if token.blank?
      render json: { status: 401, message: "No token found" }, status: :unauthorized and return
    end

    begin
      payload = JWT.decode(token, Rails.application.credentials.fetch(:secret_key_base)).first
      user = User.find(payload['sub'])

      if user
        render json: {
          status: :ok,
          message: "User signed out successfully"
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Invalid token or user not found"
        }, status: :unauthorized
      end
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      render json: {
        status: 401,
        message: "Invalid token"
      }, status: :unauthorized
    end
  end
end
