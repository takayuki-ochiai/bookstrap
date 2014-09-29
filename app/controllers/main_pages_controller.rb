class MainPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = current_user.microposts.build if signed_in?
      @feed_items = current_user.feed.paginate(page: params[:page])
    else
      @feed_items = Micropost.limit(10).paginate(page: params[:page])
    end
  end
end
