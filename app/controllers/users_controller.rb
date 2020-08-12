class UsersController < ApplicationController
  before_action :is_logged_in_user, only: [:edit, :destroy, :index, :update, :followers, :following]
  before_action :is_correct_user,   only: [:edit, :update]
  before_action :is_admin_user,     only: [:destroy]
  
  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params) # Strong Parameter で マスアサインメント脆弱性防止
      # 更新成功
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # before アクション
    def is_correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def is_admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
