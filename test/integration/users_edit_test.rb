require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    # fixture ファイル users.yml から シンボル :michael をキーにしてユーザを参照
    @user = users(:michael)
  end
  
  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password: "foo",
                                              password_confirmation: "bar"
                                            }
                                    }
    assert_template 'users/edit'
  end
  
  test "successful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
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
  
end
