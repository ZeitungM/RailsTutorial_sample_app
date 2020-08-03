class StaticPagesController < ApplicationController
  def home
    @micropost = current_user.microposts.build if logged_in?
    
    # Ruby では 2行以上のときは前置 if 文を使うのが慣習
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end
  
  def contact
  end
end
