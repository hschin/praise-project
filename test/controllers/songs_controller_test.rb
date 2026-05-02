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

  # LIB-01: POST /songs/import with a title only enqueues SearchSongJob (web search path)
  # ImportSongJob is only enqueued when raw_lyrics are provided (paste path).
  test "POST import with title only enqueues SearchSongJob and redirects to select" do
    assert_enqueued_with(job: SearchSongJob) do
      post import_songs_path, params: { title: "讚美之泉" }
    end
    assert_redirected_to select_songs_path(title: "讚美之泉", artist: nil)
  end

  test "POST import with raw_lyrics enqueues ImportSongJob and redirects to processing" do
    assert_enqueued_with(job: ImportSongJob) do
      post import_songs_path, params: { title: "讚美之泉", raw_lyrics: "第一行歌詞" }
    end
    assert_redirected_to processing_songs_path(title: "讚美之泉", step: "generating")
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

  # EMPTY-03: When no done songs exist the index renders import prompts (no special empty-state copy)
  test "GET /songs with no done songs renders import prompt" do
    Song.where(import_status: "done").destroy_all
    get songs_url
    assert_response :success
    assert_match(/Import from web|Paste lyrics/, response.body)
  end

  # IMPORT-01: Processing page renders the generating step card
  test "processing page renders generating step copy" do
    get processing_songs_path(title: "讚美之泉", step: "generating")
    assert_response :success
    assert_match(/Generating Simplified Chinese/, response.body)
  end

  # IMPORT-02: Song show page for done song renders "Add to deck" link (i18n key: songs.add_to_deck)
  test "song show done renders add to deck link" do
    song = Song.create!(title: "Test Done Song", import_status: "done")
    get song_url(song)
    assert_response :success
    assert_match(/Add to deck/, response.body)
    assert_select "a[href*='decks']"
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
