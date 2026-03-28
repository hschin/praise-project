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

  # LIB-01: POST /songs/import enqueues job and redirects to processing page
  test "POST import enqueues job and redirects to processing" do
    assert_enqueued_with(job: ImportSongJob) do
      post import_songs_path, params: { title: "讚美之泉" }
    end
    assert_redirected_to processing_songs_path(title: "讚美之泉")
  end

  # LIB-02: GET /songs?q= returns filtered results
  test "GET index with q filters by title" do
    Song.create!(title: "宇宙之光", import_status: "done")
    Song.create!(title: "讚美之泉", import_status: "done")
    get songs_path, params: { q: "宇宙" }
    assert_response :success
    assert_select "body", /宇宙之光/
  end

  # FORM-03: Failed partial renders correct error copy with song title
  test "GET show for failed song renders Couldn't find lyrics copy with title" do
    song = Song.create!(title: "讚美之泉", import_status: "failed")
    get song_path(song)
    assert_response :success
    assert_match "Couldn't find lyrics for", response.body
    assert_match "讚美之泉", response.body
  end

  # EMPTY-03
  test "GET /songs shows empty state copy when no songs exist" do
    Song.destroy_all
    get songs_url
    assert_match(/He put a new song in my mouth/, response.body)
  end

  # IMPORT-01: Processing page renders step indicators
  test "processing page renders claude copy" do
    get processing_songs_path(title: "讚美之泉")
    assert_response :success
    assert_match(/Searching for lyrics/, response.body)
    assert_match(/Generating Simplified Chinese/, response.body)
  end

  # IMPORT-02: Song show page for done song renders "Add this song to a deck" link
  test "song show done renders add to deck link" do
    song = Song.create!(title: "Test Done Song", import_status: "done")
    get song_url(song)
    assert_response :success
    assert_match(/Add this song to a deck/, response.body)
    assert_select "a[href*='decks']", text: /Add this song to a deck/
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
