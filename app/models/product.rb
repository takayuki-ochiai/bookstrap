class Product < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :users, through: :microposts

  default_scope { order(created_at: :desc) }

  validates :title,
    presence: true,
    uniqueness: true,
    length: { maximum: 100 }

  validates :genre,
    presence: true

  validates :link,
    uniqueness: {case_sensitive: true},
    length: { maximum: 300 },
    allow_blank: true,
    format: URI::regexp(%w(http https))
end
