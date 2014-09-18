class Micropost < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  default_scope { order('created_at DESC') }
  validates :user_id,:product_id, presence: true
  validates :content, 
    presence: true,
    length:{ maximum: 400 }
  has_reputation :likes, source: :user, aggregated_by: :sum


  def self.from_users_followed_by(user)
    followed_user_ids = user.followed_user_ids
    where("user_id IN (:followed_user_ids) OR user_id = :user_id",
          followed_user_ids: followed_user_ids, user_id: user)
  end
end
