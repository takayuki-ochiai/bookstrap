class MainPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = current_user.microposts.build if signed_in?
      @feed_items = current_user.feed.paginate(page: params[:page], :per_page => 10)
      @recent_feed_items = Micropost.paginate(page: params[:page], :per_page => 10)
    else
      @feed_items = Micropost.paginate(page: params[:page])
    end
  end
end
