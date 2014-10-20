module SessionsHelper
  def sign_in(user)
    remember_token = User.new_remember_token#記憶トークンを作成してremember_tokenに格納
    cookies.permanent[:remember_token] = remember_token#自動的に期限を20年後にするクッキーの記憶トークンキーにremember_tokenを格納
    user.update_attribute(:remember_token, User.encrypt(remember_token))#ユーザーモデルの記憶トークンを検証をバイパスして更新（記憶トークンは暗号化）
    self.current_user = user#与えられたユーザーを現在のユーザーに設定するcurrent
  end

  #サインインの確認
  def signed_in?
    !current_user.nil?#現在のユーザーがnilでないかを確認している
  end

  #remember_tokenを使用して現在のユーザーを検索する。
  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def delete_item(item)
    if current_user?(item.user)
      link_to "delete", item, method: :delete,data: {confirm:"You sure?"}, title: item.content
    end
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end