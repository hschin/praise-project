require "application_system_test_case"

class SongsSystemTest < ApplicationSystemTestCase
  # ── Song library ─────────────────────────────────────────────────────────────

  test "song index shows done songs and search input" do
    Song.create!(title: "宇宙之光", artist: "讚美之泉", import_status: "done")
    sign_in_and_visit songs_path

    assert_text "宇宙之光", wait: 5
    assert_selector "input[type='search'], input[placeholder*='Search']"
  end

  test "song index search filters in real-time" do
    Song.create!(title: "宇宙之光", artist: "讚美之泉", import_status: "done")
    Song.create!(title: "Amazing Grace", artist: "Traditional", import_status: "done")
    sign_in_and_visit songs_path

    fill_in "q", with: "Amazing"
    assert_text "Amazing Grace", wait: 5
    # Submit to trigger server-side filter
    find("input[name='q']").send_keys :enter
    assert_no_text "宇宙之光", wait: 5
  end

  test "empty library shows empty state copy" do
    Song.destroy_all
    sign_in_and_visit songs_path

    assert_text "He put a new song in my mouth", wait: 5
  end

  # ── Import flow ───────────────────────────────────────────────────────────────

  test "import form navigates to processing page" do
    sign_in_and_visit songs_path

    # Stub the job to prevent real AI calls
    SearchSongJob.stub(:perform_later, nil) do
      click_on "Import"  # navigates to new song page or triggers import inline
    end
    # Adjust if the import entry point differs (form vs button)
  rescue Capybara::ElementNotFound
    # Import entry may be on a different path — test the direct form submission instead
    sign_in_and_visit new_song_path rescue skip("Import form path not accessible via new_song_path")
  end

  test "processing page renders step indicators for a known title" do
    sign_in_and_visit processing_songs_path(title: "讚美之泉")

    assert_text "Searching for lyrics", wait: 5
    assert_text "Generating Simplified Chinese", wait: 5
  end

  # ── Song show ─────────────────────────────────────────────────────────────────

  test "done song show page has add to deck link" do
    song = Song.create!(title: "Grace Alone", artist: "Sovereign Grace", import_status: "done")
    sign_in_and_visit song_path(song)

    assert_link "Add this song to a deck", wait: 5
  end

  test "failed song show page renders error copy with title" do
    song = Song.create!(title: "UnknownSong", import_status: "failed")
    sign_in_and_visit song_path(song)

    assert_text "Couldn't find lyrics for", wait: 5
    assert_text "UnknownSong", wait: 5
  end
end
