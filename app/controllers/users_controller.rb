class UsersController < ApplicationController
  before_action :set_user, only: :show
  before_action :signed_in_user, only: [:edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @search = User.search(params[:q])
    @users = @search.result.paginate(page: params[:page])
  end

  def show
  end

  def new
    @user=User.new
    render layout: "no_side"
  end


  def create
    #ビューから送られてきたデータがparamsに入っているので
    #これを元に新しいレコードを作成
    @user=User.new(user_params)
    if @user.save
      #保存成功の場合
      sign_in @user#この行で登録成功の場合自動ログインさせている
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      #失敗の場合
      render "new"
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    def user_params
      params.require(:user).permit(:id, :userid, :email, :password, :password_confirmation, :nickname, :introduction, :favorite_genre)
    end

    def set_user
      @user = User.find(params[:id])
      @feed_items = @user.microposts.paginate(page: params[:page])
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

=begin
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
=end
end
