class Like < ApplicationRecord
  # Validation to ensure no duplicate likes in case database-level constraint fails
  validates :user_id, uniqueness: { scope: :post_id, message: "has already liked this post" }
  belongs_to :user
  belongs_to :post
end
