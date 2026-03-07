require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "GET password reset page returns 200" do
    get new_user_password_path
    assert_response :success
  end

  test "POST password reset with valid email enqueues reset" do
    post user_password_path, params: {
      user: { email: users(:one).email }
    }
    assert_response :redirect
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test "POST password reset with unregistered email returns unprocessable entity" do
    post user_password_path, params: {
      user: { email: "nobody@example.com" }
    }
    assert_response :unprocessable_entity
  end
end
