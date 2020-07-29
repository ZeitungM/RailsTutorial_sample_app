class MicropostsController < ApplicationController
  before_action :is_logged_in_user, only: [ :create, :destroy]
  
  def create
  end
  
  def destroy
  end
end
