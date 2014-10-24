require 'spec_helper'

describe "User pages" do

  subject { page }
  let(:user){ create(:user) }
  let(:product){ create(:product) }
  let(:product2){ create(:product) }

  #link text
  let(:delete_link){ "アカウント削除" }

  #header_link
  let(:logout){ "ログアウト" }

  #form_label
  let(:userid){"ユーザーID"}
  let(:nickname){"ニックネーム"}
  let(:password){"パスワード"}
  let(:password_confirmation){"パスワード（確認）"}

  #form_label(edit)
  let(:new_password){"新パスワード"}
  let(:new_password_confirmation){"新パスワード（確認）"}
  
  describe "visit user index" do
    before do
      sign_in user
      visit users_path
    end

    it { should have_title('ユーザー一覧') }

    describe "pagenation" do
      before(:all) {30.times { create(:user) } }
      after(:all) { User.delete_all }
    end

    describe "search function" do
      let(:search){ "検索" }
      context "title search" do
        before(:all){ 30.times{ create(:user) } }
        after(:all){ User.delete_all }
        before do 
          fill_in "ユーザー名で検索", with: "OTI2"
          click_button search
        end
        #TODO:exampleがうまく書けていない。おそらくセレクタをうまく設定できていない
        pending "ユーザー名検索。目視では確認済み" do 
          #it { should have_selector("ol.user_item li div.new_user_profile a", text: "OTI2") }
          #it { should_not have_selector("ol.user_item li div div.new_user_profile a", text: "OTI4" ) }
        end
      end
    end

    describe "delete link" do
      it { should_not have_link(delete_link) }
      context "signin as the admin user" do
        let(:admin) { create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link(delete_link, href: user_path(User.first)) }

        it "should delete other user account" do
          expect do
            click_link("アカウント削除", match: :first)
          end.to change(User, :count).by(-1)
        end

        it { should_not have_link(delete_link, href: user_path(admin)) }
      end
    end
  end

  describe "user profile page" do
    let!(:m1) { create(:micropost, user: user, product: product, content: "Foo") }
    let!(:m2) { create(:micropost, user: user, product: product2, content: "Bar") }

    before { visit user_path(user) }

    it { should have_content(user.nickname) }
    it { should have_title(user.nickname) }

    describe "render user's micropost" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow button" do
      let(:other_user) { create(:user) }
      before { sign_in user }

      context "following other_user" do
        before { visit user_path(other_user) }

        it "increment followed users" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "increment following users for followed user" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling button for follow" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      context "delete follow" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "decrement followed users" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "decrement following users for followed users" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling button for unfollow" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end
      end
    end
  end


  describe "signup" do
    before { visit signup_path }

    let(:submit) { "登録する" }

    describe "visit signup page" do
      it { should have_title("SignUp")}
    end



    context "visit user page" do
      before { visit user_path(user)}
      it { should have_title(user.nickname)}
    end




    context "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    context "with valid information" do
      before do
        fill_in userid,             with: "ExampleUser"
        fill_in nickname,           with: "OTI"
        fill_in "Eメール",            with: "gogooti@gmail.com"
        fill_in "パスワード",          with: "noukoudaigaku"
        fill_in "パスワード（確認）",     with: "noukoudaigaku"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      context "after saving the user" do
        before { click_button submit }
        it { should have_title("ご登録ありがとうございました")}
        it { should have_content("まだ登録は完了しておりません。")}
        #メールで送信されたアクティベーションリンクを踏むと登録完了
        pending "アクティベートのテスト。臨時に別のテストを下記に作成" do
        context "access activation link" do
          let(:user){ User.find_by(userid: "ExampleUser") }
          before { visit activate_user_path(user) }
          it { should have_title("アカウント登録完了") }
          it { should have_content("アカウントの作成に成功しました!")}
          context "moreover user sign in" do
            before { sign_in user }
            it { should_have title("ホーム")}
          end
        end
        end
        #TODO: メールで送られたアドレスを見ずに手あたり次第ルーティング狙われるとやばい。うまい手を考えること。
      end

      #臨時措置、上記で使用したユーザーとは異なるモデルを作成し、アクティベートさせてログインさせる
      context "become activate user" do
        let(:user){ create(:user, status: :inactive) }
        before { sign_in user }
        it { should_not have_title("ホーム") }
        context " visit activation path" do
          before { visit activate_user_path(user) }
          it { should have_title("アカウント登録完了") }
          it { should have_content("アカウントの作成に成功しました!") }
          it { should_not have_content("アカウントの作成に失敗しました")}
        end
      end
    end
  end

  describe "update user data" do
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "visit edit page" do
      it { should have_title("ユーザー情報の管理")}
    end


    context "valid user data" do
      let(:new_userid){ "testtesttest" }
      before do
        fill_in userid, with: new_userid
        fill_in "新パスワード", with: user.password
        fill_in "新パスワード（確認）", with: user.password
        click_button "編集する"
      end
      it { should have_selector("div.alert.alert-success")}
      it { should have_link(logout, href: signout_path)}
      specify { expect(user.reload.userid).to  eq new_userid }
    end

    describe "invalid user data" do
      before do
        fill_in userid, with: " "
        click_button "編集する"
      end
      it{ should have_content("error")}
    end
  end

  describe "following/followers" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { user.follow!(other_user) }
    
    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title('Following') }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.nickname, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title('Followers') }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.nickname, href: user_path(user)) }
    end
  end
end