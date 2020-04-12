require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  test "invalid signup information" do
    get signup_path # get でユーザ登録ページへアクセス
    assert_no_difference 'User.count' do # assert_no_difference ブロックの実行前後で User.count が変化しないことを確認
      # post メソッドでリクエストを送信 (User.new に使うデータをハッシュ params[:user] にまとめる )
      post signup_path, params:
      {
        user:
          {
            name: "",
            email: "user@invalid",
            password: "foo",
            password_confirmation: "bar"
          }
      }
    end
    
    assert_template 'users/new'
    assert_select   'form[action="/signup"]'
    assert_select   'div#error_explanation'
    assert_select   'div.field_with_errors'
  end
  
  test "valid signup information" do
    get signup_path # get でユーザ登録ページへアクセス
    assert_difference 'User.count', 1 do
    # post メソッドでリクエストを送信 (User.new に使うデータをハッシュ params[:user] にまとめる )
    post signup_path, params:
    {
      user:
        {
          name: "Example User2",
          email: "user2@example.com",
          password: "password",
          password_confirmation: "password"
        }
    }
    end
    follow_redirect! # POST リクエスト送信後、指定されたリダイレクト先に移動する
    assert_template 'users/show'
    assert_not      flash.blank?
    assert logged_in_for_test?
    
  end
  
end
