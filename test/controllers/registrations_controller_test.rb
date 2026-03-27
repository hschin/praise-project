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

  test "GET edit account page returns 200 with Sanctuary Stone tokens" do
    sign_in users(:one)
    get edit_user_registration_path
    assert_response :success
    assert_match "focus:border-primary", response.body
    assert_match "border-outline-variant", response.body
  end

  # AUTH-01
  test "GET sign in page renders Newsreader headline wordmark" do
    get new_user_session_path
    assert_response :success
    assert_match(/font-headline/, response.body)
    assert_match(/text-primary/, response.body)
  end

  # AUTH-01
  test "GET sign up page renders Sanctuary Stone card wrapper" do
    get new_user_registration_path
    assert_match(/rounded-xl/, response.body)
    assert_match(/bg-surface-container-lowest/, response.body)
  end
end
