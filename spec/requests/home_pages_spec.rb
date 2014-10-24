require 'spec_helper'

describe "HomePages" do
  subject { page }
  let(:user){ create(:user) }
  let(:product) { create(:product) }
  let(:product2) { create(:product) }
  context "visit home page" do
    before { visit root_path }
    it { should have_title("ホーム") }
  end

  #TODO: 作ったマイクロポスト一つ、なおかつセレクタの確認もできていないので直す
  context "user is not signin"do
    before do
      user.microposts.create(content: "test", product_id: product.id)
      visit root_path
    end
    it { should have_content("test")}
  end

  context "user is signin" do
    before do
      user.microposts.create(content: "test", product_id: product.id)
      user.microposts.create(content: "test", product_id: product2.id)
      sign_in user
      visit root_path
    end

    it "should render users feed" do
      user.feed.each do |item|
        expect(page).to have_selector("li##{item.id}", text: item.content)
      end
    end

    describe "following/follower counts" do
        let(:other_user) { create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_content("フォロー 0") }
        it { should have_content("フォロワー 1") }

        #it { should have_link("フォロー 0", href: following_user_path(user)) }
        #it { should have_link("フォロワー 1", href: followers_user_path(user)) }
    end

    describe "pagenation" do
      before(:all) {100.times { create(:user) } }
      after(:all) { User.delete_all }

      it "should render 30 users per page" do
        Micropost.paginate(page: 1).each do |micropost|
          expect(page).to have_selector('li', text: user.nickname)
        end
      end
    end

    #指定された文字を入れたボタンを持っているか。リンクは別途確認すること
    describe "user_nav" do
      it { should have_button("感想の投稿はこちら") }
      it { should have_button("ユーザー情報の管理はこちら") }
      it { should have_button("投稿内容の管理はこちら") }
    end
  end

  describe "introduction page" do
    before { visit introduction_path }
    it { should have_title("Bookstrapとは") }
    it { should have_content("Bookstrapは") }
  end
end
