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

  # LIB-03: PATCH /songs/:id updates lyrics and pinyin
  test "PATCH update saves edited lyrics and pinyin" do
    song = songs(:one)
    lyric = lyrics(:one)
    patch song_path(song), params: {
      song: {
        title: song.title,
        lyrics_attributes: {
          "0" => {
            id: lyric.id,
            section_type: "bridge",
            content: "新的歌詞",
            pinyin: "xīn de gē cí",
            position: lyric.position
          }
        }
      }
    }
    assert_redirected_to song_path(song)
    lyric.reload
    assert_equal "bridge", lyric.section_type
    assert_equal "新的歌詞", lyric.content
    assert_equal "xīn de gē cí", lyric.pinyin
  end
end
