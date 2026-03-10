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

  # LIB-01: POST /songs/import creates song and enqueues job
  test "POST import creates song and redirects to show" do
    assert_difference("Song.count", 1) do
      post import_songs_path, params: { title: "讚美之泉" }
    end
    assert_redirected_to song_path(Song.last)
    assert_enqueued_with(job: ImportSongJob)
  end

  # LIB-02: GET /songs?q= returns filtered results
  test "GET index with q filters by title" do
    Song.create!(title: "宇宙之光", import_status: "done")
    Song.create!(title: "讚美之泉", import_status: "done")
    get songs_path, params: { q: "宇宙" }
    assert_response :success
    assert_select "body", /宇宙之光/
  end
end
