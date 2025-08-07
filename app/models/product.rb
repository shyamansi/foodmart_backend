class Product < ApplicationRecord
    include Rails.application.routes.url_helpers
    # enum status: { active: "active", pending: "pending", archived: "archived" }
    has_one_attached :image
    belongs_to :user, optional: true
    has_many :order_items

      def image_url
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) if image.attached?
  end
end
