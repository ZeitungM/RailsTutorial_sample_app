require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    ActionMailer::Base.deliveries.clear #  Action Mailer から送信されたメールの配列を保持する変数を初期化
    @user = users(:michael)
  end
  
  test "password resets" do
    get new_password_reset_url
    assert_template 'password_resets/new'
    
    # メールアドレスが無効 -> flash を出力して同じページを描画
    # params はリクエストを処理するメソッド PasswordReset#create の引数に倣う
    post password_resets_path, params: {  password_reset:  { email: "" }  } 
    assert_not flash.empty?
    assert_template 'password_resets/new'
    
    # メールアドレスが有効
    post password_resets_path, params: {  password_reset:  { email: @user.email }  } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    
    # パスワード再設定フォームのテスト
    user = assigns(:user) # assigns で controller のインスタンス変数 @user にアクセス
    
    # メールアドレスが無効
    get edit_password_reset_path( user.reset_token, email: "" )
    assert_redirected_to root_url
    
    # 無効なユーザ
    user.toggle!(:activated)
    get edit_password_reset_path( user.reset_token, email: @user.email )
    assert_redirected_to root_url
    user.toggle!(:activated)
    
    # メールアドレスが有効、トークンが無効
    get edit_password_reset_path( 'wrong token', email: @user.email )
    assert_redirected_to root_url
    
    # メールアドレスもトークンも有効
    get edit_password_reset_path( user.reset_token, email: @user.email )
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                user:  { password:              "foobaz",
                         password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    
    # パスワードが空
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                user:  { password:              "",
                         password_confirmation: "" } }
    assert_select 'div#error_explanation'
    
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                user:  { password:              "foobar",
                         password_confirmation: "foobar" } }
    assert logged_in_for_test?
    assert_not flash.empty?
    assert_nil user.reload.reset_digest
    assert_redirected_to user
  end
  
  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
      params: { password_reset: { email: @user.email } }
    
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
      params: { email: @user.email,
                user:  { password: "foobar",
                         password_confirmation: "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
  
end
