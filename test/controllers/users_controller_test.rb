require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should get new" do
    get signup_path
    assert_response :success
  end
  
  test "should redirect edit when not logged in" do
    # ログインしていない状態で ユーザ編集ページにアクセスしたら弾かないといけない
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    # ログインしていない状態で ユーザ編集の HTTP リクエストをしたら弾かないといけない
    patch user_path(@user), params:{  user: { name:  @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect edit when logged in as wrong user" do
    # 違うユーザのユーザ編集ページにアクセスしたら弾かないといけない
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should redirect update when logged in as wrong user" do
    # 違うユーザのユーザ編集の HTTP リクエストをしたら弾かないといけない
    log_in_as(@other_user)
    patch user_path(@user), params:{  user: { name:  @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  # ログインしてない状態でユーザ一覧ページにアクセスされたら弾く
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
  
  test "should not allow the admin-attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
                                            user: {
                                              password:              @other_user.password,
                                              password_confirmation: @other_user.password_confirmation,
                                              admin:                 true
                                            }
                                          }
    assert_not @other_user.reload.admin?
  end
  
  test "should redirect login_url when not logged-in user" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end
  
  test "should redirect root_url when not admin user" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
  
end
