class SessionsController < ApplicationController
  layout "no_side"
  def new
  end

  def create
    user = User.find_by(userid: params[:session][:userid])
    #userが有効であることとuserのauthenticateが成功することの両方がtrueのとき認証成功
    if user && user.authenticate(params[:session][:password])
      if user.active?
        # ユーザーをサインインさせ、ユーザーページ (show) にリダイレクトする。
        sign_in user
        redirect_back_or root_path
      else
        flash.now[:error] = 'メール認証が完了していません!'
        render 'new'
      end
    else
      # エラーメッセージを表示し、サインインフォームを再描画する。
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
