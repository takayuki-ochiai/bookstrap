class MainPagesController < ApplicationController
  #サインインしている場合、最新の投稿だけでなくフォロワーの投稿も表示させる
  def home
    if signed_in?
      @feed_items = current_user.feed.paginate(page: params[:page], :per_page => 10)
      @recent_feed_items = Micropost.paginate(page: params[:page], :per_page => 10)
    else
      @feed_items = Micropost.paginate(page: params[:page])
    end
  end

  def introduction
    render layout: "no_side"
  end
end
