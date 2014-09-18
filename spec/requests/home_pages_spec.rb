require 'spec_helper'

describe "HomePages" do
  subject { page }
  let(:user){ create(:user) }
  let(:product) { create(:product) }
  let(:product2) { create(:product) }
  let(:micropost) { user.microposts.build(content: "test", product_id: product.id) }


  context "visit home page" do
    before { visit root_path }
    it { should have_title("Index") }
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

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
    end

    describe "pagenation" do
      before(:all) {100.times { create(:user) } }
      after(:all) { User.delete_all }

      it "should render 30 users per page" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.nickname)
        end
      end
    end
  end
end
