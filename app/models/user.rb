class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :products, through: :microposts
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :evaluations, class_name: "ReputationSystem::Evaluation", as: :source

  before_save { self.email = email.downcase }
  before_save { self.userid = userid.downcase }
  before_create :create_remember_token

  validates :userid,
    presence: true,
    uniqueness: {case_sensitive: true},
    length: {in: 1..20}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email,
    presence: true,
    uniqueness: {case_sensitive: true },
    length: { maximum:50 },
    format: { with: VALID_EMAIL_REGEX }

  validates :nickname,
    presence: true,
    uniqueness: {case_sensitive: true },
    length: { maximum:20 }

    has_secure_password
    validates :password,
      length:{ minimum:6 , maximum:30 }, :if => :validate_password?
    def validate_password?
      password.present? || password_confirmation.present?
    end#アカウントのアクティベーション時のパスワード認証の回避。
    #TODO: 意味を調べて理解しておくこと！

  state_machine :status, :initial => :inactive do
    state :active
    state :inactive

    event :activate do
      transition :inactive => :active
    end

    event :inactivate do
      transition :active => :inactive
    end
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed
     Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  def liked?(micropost)
    evaluations.where(target_type: micropost.class, reputation_name: :likes, target_id: micropost.id).present?
  end

  def wanna_read?(micropost)
    product = micropost.product
    evaluations.where(target_type: product.class, reputation_name: :wanna_read, target_id: product.id).present?
  end

  private
    #記憶トークンの作成
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
