namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
  make_users
  make_products
  make_microposts
  make_relationships
  end
end
def make_users
  admin = User.create!(userid: "takayuki ochiai",
                       email: "gogooti@gmail.com",
                       nickname: "OTI",
                       favorite_genre: "戦記",
                       password: "suidenOTI",
                       password_confirmation: "suidenOTI",
                       admin: true)
  99.times do |n|
    userid  = "exampleuser#{n+1}"
    email = "example-#{n+1}@railstutorial.jp"
    password  = "examplepass#{n+1}"
    nickname = "example-nickname#{n+1}"
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
  64.times do |n|
    title = "小説サンプル No.#{n+1}"
    case n+1
      when 1..4
        genre = "文学"
      when 5..8
        genre = "恋愛"
      when 9..12
        genre = "歴史"
      when 13..16
        genre = "推理"
      when 17..20
        genre = "ファンタジー"
      when 21..24
        genre = "SF"
      when 25..28
        genre = "ホラー"
      when 29..32
        genre = "コメディ"
      when 33..36
        genre = "冒険"
      when 37..40
        genre = "学園"
      when 41..44
        genre = "戦記"
      when 45..48
        genre = "童話"
      when 49..52
        genre = "詩"
      when 53..56
        genre = "エッセイ"
      when 57..60
        genre = "リプレイ"
      when 61..64
        genre = "その他"
    end
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
    content = "Sample micropost No.#{n+1}"
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

