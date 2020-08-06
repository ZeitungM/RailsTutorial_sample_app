class MicropostsController < ApplicationController
  before_action :is_logged_in_user, only: [ :create, :destroy]
  before_action :correct_user,      only: :destroy
  
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end
  
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # request.referrer で一つ前の URL (DELETE リクエストが発行されたページ) にリダイレクトする
    redirect_to request.referrer || root_url
    # redirect_back(fallback_location: root_url) # rails 5 からはこのような書き方でも可
  end
  
  private
    def micropost_params
      # content のみ変更を加えることを許可する
      params.require(:micropost).permit(:content, :picture)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
