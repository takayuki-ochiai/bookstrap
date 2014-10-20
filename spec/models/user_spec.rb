require 'spec_helper'

#usersテーブルへの検証
describe User do
  let(:product) {create(:product) }
  let(:product2) {Product.new(id: 2, title: "test", genre:"学ぶ系", link:"http://d.hatena.ne.jp/suginoy/20110507/p1")}
  let(:user) {create(:user, userid: "Example", email: "suidenOTI@gmail.com",
                               password:"foobar",password_confirmation:"foobar")}

  subject { user }
  describe "各属性の存在検証" do
    it { should respond_to(:id) }
    it { should respond_to(:userid)}
    it { should respond_to(:nickname)}
    it { should respond_to(:introduction)}
    it { should respond_to(:favorite_genre)}
    it { should respond_to(:email)}
    it { should respond_to(:password_digest) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:remember_token)}
    it { should respond_to(:authenticate)}
    it { should respond_to(:admin) }
    it { should respond_to(:microposts)}
    it { should respond_to(:feed) }
    it { should respond_to(:relationships) }
    it { should respond_to(:followed_users) }
    it { should respond_to(:following?) }
    it { should respond_to(:follow!) }
    it { should respond_to(:reverse_relationships) }
    it { should respond_to(:followers) }
    it { should respond_to(:status) }
    it { should respond_to(:active?) }
    it { should respond_to(:inactive?) }

    it { should be_valid }
    it { should_not be_admin }

    context "set admin property" do
      before do
        user.save!
        user.toggle!(:admin)
      end

      it { should be_admin }
    end
  end
  context "without password is invalid" do

    let(:user){ User.new(userid: "Example", email: "suidenOTI@gmail.com",
                                nickname: "oti", password:"",password_confirmation:"") }
    it { should_not be_valid}
    it { should respond_to(:authenticate) }
  end

  #emailがない時検証失敗する
  context "without email is invalid" do
    let(:user){ User.new(userid: "Example", email: "",
                                nickname: "oti", password:"password",password_confirmation:"password") }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before do
      user.save
    end

    let(:found_user) { User.find_by(email: user.email) }

    context "with valid password" do
      it { should eq found_user.authenticate(user.password) }
    end

    context "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "Too short password is invalid" do
    let(:user){ User.new(userid: "Example", email: "suidenOTI@gmail.com",
                                password:"suide",password_confirmation:"suide")}
    it { should_not be_valid}
  end

  describe "remember token" do
    before { user.save }
    its(:remember_token){ should_not be_blank }
    #上記はこのコードと等価it { expect(@user.remember_token).not_to be_blank }
  end

  describe "relationship of microposts" do
    before do 
      user.save
    end 

    let!(:older_micropost) do
      create(:micropost, content: "hogehoge", user_id: user.id, product_id: product.id, created_at: 1.day.ago)
    end

    let!(:newer_micropost) do
      create(:micropost, content: "hogehoge", user_id: user.id, product_id: product2.id, created_at: 1.hour.ago)
    end

    it "show newer micropost firstly" do      #older_micropost
      expect(user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "delete microposts when user is deleted" do
      microposts = user.microposts.to_a
      user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end


    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user), product_id: 120)
      end
      let(:followed_user) { FactoryGirl.create(:user) }
      before do
        user.follow!(followed_user)
        followed_user.microposts.create!(content: "Lorem ipsum", product_id: product.id)
        #3.times { |n| followed_user.microposts.create!(content: "Lorem ipsum", product_id: n) }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "following function" do
    let(:other_user) { create(:user) }
    before do
      user.save
      user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(user) }
    end

    context "and unfollowing" do
      before { user.unfollow!(other_user) }
      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
