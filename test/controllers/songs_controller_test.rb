require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "unauthenticated GET /songs redirects to sign in" do
    sign_out @user
    get songs_url
    assert_redirected_to new_user_session_path
  end

  test "authenticated GET /songs returns 200" do
    get songs_url
    assert_response :success
  end
end
