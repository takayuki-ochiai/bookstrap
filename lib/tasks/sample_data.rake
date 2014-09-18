namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
  make_users
  make_products
  make_microposts
  make_relationships
=begin
    User.create!(userid: "takayuki ochiai",
                 email: "gogooti@gmail.com",
                 nickname: "OTI",
                 favorite_genre: "やる夫スレ",
                 password: "suidenOTI",
                 password_confirmation: "suidenOTI",
                 admin: true)
=end
  end
end
def make_users
  admin = User.create!(userid: "takayuki ochiai",
                       email: "gogooti@gmail.com",
                       nickname: "OTI",
                       favorite_genre: "やる夫スレ",
                       password: "suidenOTI",
                       password_confirmation: "suidenOTI",
                       admin: true)
  99.times do |n|
    userid  = "exampleuser#{n+1}"
    email = "example-#{n+1}@railstutorial.jp"
    password  = "examplepass#{n+1}"
    nickname = Faker::Name.name
    favorite_genre = "test"
    User.create!(userid: userid,
                 email: email,
                 nickname: nickname,
                 favorite_genre: favorite_genre,
                 password: password,
                 password_confirmation: password)
  end
end

def make_products
  60.times do |n|
    title = "やる夫は~#{n+1}"
    genre = "学ぶ系"
    link = "http://www.yahoo.co.jp/#{n+1}"
    Product.create!(title:title, genre: genre, link: link)
  end
end



def make_microposts
  products = Product.all
  50.times do |n|
    first_product = products.first
    second_product = products.second
    user = n+1 #要訂正
    content = "Create #{n+1} minutes ago"
    created_time = (n+1).minute.ago
    Micropost.create!(content: content, user_id: user, product_id: first_product.id, created_at: created_time)
    Micropost.create!(content: content, user_id: user, product_id: second_product.id, created_at: created_time)
  end
end





def make_relationships
  users = User.all
  user  = users.first
  followed_users = users[2..50]
  followers      = users[3..40]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each      { |follower| follower.follow!(user) }
end

