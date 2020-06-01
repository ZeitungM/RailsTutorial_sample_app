require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    # fixture ファイル users.yml から シンボル :michael をキーにしてユーザを参照
    @user = users(:michael)
  end
  
#  test "unsuccessful edit" do
#    # リダイレクトで edit 用のテンプレートが描画されなくなるのでこのテストを削除
#    log_in_as(@user)
#    get edit_user_path(@user)
#    assert_template 'users/edit'
#    patch user_path(@user), params: { user: { name: "",
#                                              email: "foo@invalid",
#                                              password: "foo",
#                                              password_confirmation: "bar"
#                                            }
#                                    }
#    assert_template 'users/edit'
#  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: ""
                                            }
                                    }
    # flash が空でないことのテスト
    assert_not flash.empty?
    # リダイレクトのテスト
    assert_redirected_to @user
    # データベースの更新のテスト
    @user.reload # 最新のユーザ情報を読み直す
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
  
  # 演習 10.2.3.1: friendly forwarding の後、 login_path を介してログインした際、 edit_user_path にリダイレクトされないことのテスト
  # ( friendly forwarding は 1 回だけ )
  test "forwarding_url must be nil after friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    
    delete logout_path
    get login_path
    assert_nil session[:forwarding_url]
    log_in_as(@user)
    
    # リダイレクトのテスト
    assert_redirected_to @user
  end
  
end
