class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :edit, :destroy, :likes, :dislikes]

  #投稿作成者かadmin権限がある場合、削除が可能になる
  before_action :correct_user,   only: [:edit, :destroy]

  before_action :set_micropost,  only: [:edit, :update, :likes, :dislikes]

  def index
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      flash[:failure] = "Micropost created error!"
      redirect_to root_url
    end
  end

  def edit
    @product = @micropost.product
  end

  def update

    if @micropost.update_attributes(micropost_params)
      flash[:success] = "投稿の編集が完了しました"
      redirect_to root_url
    else
      @product = @micropost.product
      render "edit"
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  def likes
    redeirect_to root_url if @micropost.user == current_user
    @micropost.add_evaluation(:likes, 1, current_user)
    @likes_num = @micropost.reputation_for(:likes).to_i
    respond_to do |format|
      format.html {redirect_to :back}
      format.js
    end
  end

  def dislikes
    redeirect_to root_url if @micropost.user == current_user
    @micropost.delete_evaluation(:likes, current_user)
    @likes_num = @micropost.reputation_for(:likes).to_i
    respond_to do |format|
      format.html {redirect_to :back}
      format.js
    end
  end

  private
    def micropost_params
      params.require(:micropost).permit(:content, :product_id, :user_id)
    end

    def correct_user
      @micropost = Micropost.find_by(id: params[:id])
      unless current_user.admin? || current_user?(@micropost.user)
        redirect_to root_path
      end
    end

    def set_micropost
      @micropost = Micropost.find(params[:id])
    end

    def set_product
      @product = Product.find(params[:id])
      @microposts = @product.microposts.paginate(page: params[:page])
    end
end