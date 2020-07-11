require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @user      = users(:michael)
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @inactivated = users(:inactivated)
  end
  
  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select   'div.pagination', count:2
    User.paginate(page: 1).each do |user| # User.pagenate(1) 内にある各ユーザへのリンクがあることを確認
      if !user.activated? then
        next
      end
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
  
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select   'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      if !user.activated? then
        next
      end
      
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    
  end
  
  test "should not show in index an unactivated account" do
    log_in_as(@inactivated)
    assert_not @inactivated.activated?
    
    get users_path
    assert_select "a[href=?]", user_path(@inactivated), count: 0
  end
  
  test "should redirect to root from inactivated account page" do
    log_in_as(@inactivated)
    assert_not @inactivated.activated?
    
    get user_path(@inactivated)
    assert_select "a[href=?]", user_path(@inactivated), count: 0
    #follow_redirect! # POST リクエスト送信後、指定されたリダイレクト先に移動する
    assert_redirected_to root_path
  end
  
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
end
