# config/initializers/omniauth_patch.rb

require 'omniauth-oauth2'

OmniAuth::Strategies::OAuth2.class_eval do
  def callback_phase
    if request.params['error']
      fail!(request.params['error'], OmniAuth::Strategies::OAuth2::CallbackError.new(
        request.params['error'],
        request.params['error_description'],
        request.params['error_uri']
      ))
    else
      self.access_token = build_access_token

      if access_token && access_token.respond_to?(:expired?) && access_token.expired?
        fail!(:token_expired, OmniAuth::Strategies::OAuth2::CallbackError.new(:token_expired, 'The OAuth2 token has expired'))
      else
        super
      end
    end
  rescue ::OAuth2::Error, OmniAuth::Strategies::OAuth2::CallbackError => e
    fail!(:invalid_credentials, e)
  end
end
