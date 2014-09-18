class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy, :likes, :dislikes]
  before_action :correct_user, only: :destroy
  before_action :set_micropost, only: [:likes, :dislikes]
  def index
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'main_pages/home'
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
=begin
    @value = params[:type]
    @micropost = Micropost.find(params[:id])
    if @value == "up"
      @micropost.add_evaluation(:likes, 1, current_user)
    else
      @micropost.delete_evaluation(:likes, current_user)
    end
=end
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
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
    #TODO: いいね用のparamsを作ってbeforeactionする必要あり？
    def set_micropost
      @micropost = Micropost.find(params[:id])
    end
end