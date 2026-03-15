require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "GET sign up page returns 200" do
    get new_user_registration_path
    assert_response :success
  end

  test "valid sign up redirects to decks" do
    post user_registration_path, params: {
      user: {
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to decks_path
  end

  test "invalid sign up re-renders form" do
    post user_registration_path, params: {
      user: {
        email: "",
        password: ""
      }
    }
    assert_response :unprocessable_entity
  end

  test "GET edit account page returns 200 with warm palette classes" do
    sign_in users(:one)
    get edit_user_registration_path
    assert_response :success
    assert_match "focus:ring-rose-600", response.body
    assert_match "border-stone-200", response.body
  end
end
