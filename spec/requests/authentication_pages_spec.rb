require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
  
  describe "SignIn page" do
    before { visit signin_path }

    context "visit signin page" do
      it { should have_title("SignIn")}
    end

    context "sign in is Invalid" do
      before { click_button "Sign in" }

      it { should have_title("SignIn")}
      it { should have_selector("div.alert.alert-error", text: "Invalid")}

      context "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    context "signin is valid" do
      let(:user){ create(:user) }
      before { valid_signin(user) }#utility参照

      it { should have_link("Sign out", href: signout_path) }#utility参照
      it { should have_title(user.nickname) }
      it { should_not have_selector("div.alert.alert-error", text: "Invalid") }
      it { should have_link("Profile", href: user_path(user)) }

      it { should_not have_link("Sign in", href: signin_path) }


      context "signout user" do
        before{ click_link "Sign out" }
        it { should have_link("Sign in", href: signin_path)}
      end
    end

    describe "update user infomation" do
      let(:user){ FactoryGirl.create(:user) }
      before { sign_in user}

      it { should have_title(user.nickname) }
      it { should have_link('Users', href: users_path) }
      it { should have_link("Profile", href: user_path(user))}
      it { should have_link("Settings", href: edit_user_path(user)) }
      it { should have_link("Sign out", href: signout_path) }
      it { should_not have_link("Sign in", href: signin_path) }

        context "user signout" do
          before { click_link "Sign out" }

          it { should_not have_title(user.nickname) }
          it { should_not have_link('Profile', href: user_path(user))}
          it { should_not have_link('Settings', href: edit_user_path(user)) }
          it { should_not have_link('Sign out', href: signout_path) }
          it { should have_link('Sign in', href: signin_path) }
        end
    end

    describe "authentication" do

      describe "guest_user" do
        let(:user) { create(:user) }

        describe "user controller" do
          context "visit edit page" do
            before { visit edit_user_path(user) }
            it { should_not have_title('Edit user') }
          end

          context "update user data" do
            before { patch user_path(user) }
            specify { expect(response).to redirect_to(signin_path) }
          end

          context "visit user index" do
            before { visit users_path }
            it { should have_title("SignIn") }
          end

          context "delete micropost" do
            context "fail deleting micropost" do
              before { post microposts_path }
              specify { expect(response).to redirect_to(signin_path) }
            end

            context "return signin page" do
              before { delete micropost_path(FactoryGirl.create(:micropost)) }
              specify { expect(response).to redirect_to(signin_path) }
            end
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
            fill_in "Userid", with: user.userid
            fill_in "Password", with: user.password
            click_button "Sign in"
          end

          context "redirect to edit page" do
            it { should have_title("Edit user") }
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
