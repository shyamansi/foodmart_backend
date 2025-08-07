# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_request, only: [:create]
 respond_to :json
 private
 
 def respond_with(resource, options={})
 Rails.logger.debug"shyammmm from ruby #{resource.inspect} and #{resource.persisted?.inspect}"
 
 if resource.persisted?
   Rails.logger.debug"shyammmm from ruby1"
  render json: {
    status: {code: 201 ,message: "User created Successfully",data: resource}
  }, status: :ok
 else
  Rails.logger.debug"shyammmm from ruby2"
  render json:{
  status:{
    message:"User could not be created! Sorry",
    errors: resource.errors.full_messages
  },
  status: :unprocessable_entity
}
end

end
end
