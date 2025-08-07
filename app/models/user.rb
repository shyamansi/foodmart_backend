class User < ApplicationRecord
# enum status: { active: "active", pending: "pending", archived: "archived" }
has_many :products
has_one :cart, dependent: :destroy
has_many :cart_items, through: :cart
has_many :orders
include Devise::JWT::RevocationStrategies::JTIMatcher
    # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :jwt_authenticatable,:omniauthable,  jwt_revocation_strategy: self,
        omniauth_providers: [:google_oauth2]

# def  jwt_payload
#  super
# end

def self.from_omniauth(auth)
  if auth.nil?
    Rails.logger.error "Omniauth auth hash is nil!"
    return nil
  end
   user = User.find_or_create_by(provider: auth.provider, uid: auth.uid) do |u|
    u.email = auth.info.email
    u.password = Devise.friendly_token[0, 20]
    u.name = auth.info.name
  end

  user
end
end 
