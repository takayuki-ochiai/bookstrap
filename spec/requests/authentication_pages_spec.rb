require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
  #ヘッダー要素
  let(:logout){ "ログアウト" }
  let(:login){  "ログイン"  }
  let(:users){ "人を探す" }
  let(:profile){ "マイページ" }
  let(:edit_user){ "ユーザー情報管理" }
  let(:top){ "TOP" }
  let(:usage){ "使い方" }

  describe "SignIn page" do
    before { visit signin_path }

    context "visit signin page" do
      it { should have_title("SignIn") }
    end

    context "sign in is Invalid" do
      before { click_button "ログイン" }

      it { should have_title("SignIn")}
      it { should have_selector("div.alert.alert-error", text: "Invalid")}

      context "after visiting another page" do 
        before { click_link top }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    context "signin is valid" do
      let(:user){ create(:user) }
      before { sign_in user }#utility参照

      it { should have_link(logout, href: signout_path) }#utility参照
      it { should have_title("ホーム") }
      it { should_not have_selector("div.alert.alert-error", text: "Invalid") }
      it { should have_link(profile, href: user_path(user)) }

      it { should_not have_link(login, href: signin_path) }


      context "signout user" do
        before{ click_link logout }
        it { should have_link(login, href: signin_path)}
      end
    end

    describe "update user infomation" do
      let(:user){ create(:user) }
      before { sign_in user}

      it { should have_title("ホーム") }
      it { should have_link(usage,     href: introduction_path) }
      it { should have_link(users,     href: users_path) }
      it { should have_link(profile ,  href: user_path(user)) }
      it { should have_link(edit_user, href: edit_user_path(user)) }
      it { should have_link(logout,    href: signout_path) }
      it { should_not have_link(login, href: signin_path) }

        context "user signout" do
          before { click_link logout }

          it { should_not have_title(user.nickname) }
          it { should_not have_link(profile, href: user_path(user)) }
          it { should_not have_link(edit_user, href: edit_user_path(user)) }
          it { should_not have_link(logout, href: signout_path) }
          it { should have_link(login , href: signin_path) }
        end
    end

    describe "authentication" do

      describe "guest_user" do
        let(:user) { create(:user) }

        describe "user controller" do
          context "visit edit page" do
            before { visit edit_user_path(user) }
            it { should_not have_title('ユーザー情報の管理') }
          end

          context "update user data" do
            before { patch user_path(user) }
            specify { expect(response).to redirect_to(signin_path) }
          end

          context "delete micropost" do
            context "fail deleting micropost" do
              before { post microposts_path }
              specify { expect(response).to redirect_to(signin_path) }
            end

            context "return signin page" do
              before { delete micropost_path(create(:micropost)) }
              specify { expect(response).to redirect_to(signin_path) }
            end
          end

          context "edit micropost" do
            before { visit edit_micropost_path(create(:micropost))}
            it { should have_title("SignIn")}
          end

          context "visiting the following page" do
            before { visit following_user_path(user) }
            it { should have_title("SignIn") }
          end

          context "visiting the followers page" do
            before { visit followers_user_path(user) }
            it { should have_title("SignIn") }
          end
        end

        describe "friendly forward" do
          before do
            visit edit_user_path(user)
            sign_in user
          end

          context "redirect to edit page" do
            it { should have_title("ユーザー情報の管理") }
          end
        end

        describe "Relationships controller" do
          context "require post relationships" do
            before { post relationships_path }
            specify { expect(response).to redirect_to(signin_path) }
          end

          context "require delete relationships" do
            before { delete relationship_path(1) }
            specify { expect(response).to redirect_to(signin_path) }
          end
        end
      end

      describe "as non-admin user" do
        let(:user) { create(:user) }
        let(:non_admin) { create(:user) }
        let(:product) { create(:product) }

        before { sign_in non_admin, no_capybara: true }
        describe "User controller" do
          describe "submitting a DELETE request to the Users#destroy action" do
            before { delete user_path(user) }
            specify { expect(response).to redirect_to(root_path) }
          end
        end

        describe "Product controller" do
          context "delete micropost" do
            before { delete product_path(product) }
            specify { expect(response).to redirect_to(root_path) }
          end

          context "edit prodoct" do
            context "visit edit product pages" do
              before { patch product_path(product) }
              it { should_not have_title("Edit #{product.title}")}
            end
          end
        end
      end
    end
  end
end
