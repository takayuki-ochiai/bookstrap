include ApplicationHelper

def valid_signin(user)
  fill_in "Userid", with: user.userid
  fill_in "Password", with: user.password
  click_button "Sign in"
end


RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end
RSpec::Matchers.define :have_signout_link do |message|
  match do |page|
    expect(page).to have_link("Sign out", href: message)
  end
end

#サインイン用ヘルパー
def sign_in(user, options={})
  if options[:no_capybara]
    # Capybaraを使用していない場合にもサインインする。
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    visit signin_path
    fill_in "Userid",    with: user.userid
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end

def sign_out(options={})
  if options[:no_capybara]
    cookies.delete(:remember_token)
  else
    click_link "Sign out" 
  end
end