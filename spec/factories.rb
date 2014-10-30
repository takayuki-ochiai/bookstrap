
FactoryGirl.define do
  factory :user do
    sequence(:userid){ |n| "takayuki ochiai#{n}"}
    sequence(:email){ |n| "gogooti#{n}@gmail.com"}
    sequence(:nickname){ |n| "OTI#{n}"}
    favorite_genre "戦記"
    sequence(:password) { |n|"suidenOTI#{n}" }
    sequence(:password_confirmation) { |n| "suidenOTI#{n}" }
    status :active #state_machineによる認証を通った状態で作成する。stateはキーで入れないと無効。

    factory :admin do
      admin true
    end
  end

  factory :other_user do
    sequence(:userid){ |n| "suiden ochiai#{n}"}
    sequence(:email){ |n| "susumeoti#{n}@gmail.com"}
    nickname "OTI-2"
    favorite_genre "恋愛"
    sequence(:password) { |n|"susumeOTI#{n}" }
    sequence(:password_confirmation) { |n| "susumeOTI#{n}" }
    status :active
  end
  
  factory :micropost do
    content "Lorem ipsum"
    #user
    sequence(:user_id){ |n| n }
    sequence(:product_id){ |n| n }
    #product
  end

  factory :product do
    sequence(:title) do |n|
      if n%2==0
        "小説#{n}"
      else
        "#{n}テスト"
      end
    end
    sequence(:genre) do |n| 
      if n%2==0
        "文学"
      else
        "恋愛"
      end
    end
    sequence(:link) { |n| "http://www.yahoo.co.jp/21#{n}" }
  end
end