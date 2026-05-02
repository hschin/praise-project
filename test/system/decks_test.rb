require "application_system_test_case"

class DecksSystemTest < ApplicationSystemTestCase
  # ── Deck index ───────────────────────────────────────────────────────────────

  test "deck index shows existing decks" do
    sign_in_and_visit decks_path
    assert_selector "h1, [class*='headline']", text: /Sunday|My|deck/i, wait: 5
    assert_current_path decks_path
  end

  test "unauthenticated user is redirected to sign in" do
    visit decks_path
    assert_current_path new_user_session_path
  end

  test "quick create navigates to the new deck editor" do
    sign_in_and_visit decks_path

    click_on "New deck"
    # Quick-create posts and redirects to the deck show page
    assert_current_path %r{/decks/\d+}, wait: 5
  end

  # ── Deck editor ──────────────────────────────────────────────────────────────

  test "deck show renders arrangement panel and song library panel" do
    sign_in_and_visit deck_path(decks(:one))

    assert_text "Arrangement", wait: 5
    assert_text "Add Songs"
  end

  test "song search filters library items" do
    Song.create!(title: "Amazing Grace", artist: "John Newton", import_status: "done")
    sign_in_and_visit deck_path(decks(:one))

    fill_in placeholder: "Search songs…", with: "Amazing"
    assert_selector "[data-song-search-target='item']", text: /Amazing Grace/, wait: 5

    # Items not matching should be hidden
    fill_in placeholder: "Search songs…", with: "ZZZNOMATCH"
    assert_no_selector "[data-song-search-target='item']:not([hidden])", wait: 5
  end

  test "inline-edit saves a new deck title" do
    sign_in_and_visit deck_path(decks(:one))

    # Click the pencil edit button on the title
    find("button[aria-label='Edit title']").click
    input = find("input[data-inline-edit-target='input']")
    input.set("Renamed Deck Title")
    input.send_keys :enter

    assert_text "Renamed Deck Title", wait: 5

    # Persist check: reload and verify
    visit deck_path(decks(:one))
    assert_text "Renamed Deck Title", wait: 5
  end

  # ── Export button states ─────────────────────────────────────────────────────

  test "export button renders in idle state on fresh deck show" do
    sign_in_and_visit deck_path(decks(:one))

    assert_selector "#export_button_#{decks(:one).id}", wait: 5
    # Idle state shows the download icon
    within "#export_button_#{decks(:one).id}" do
      assert_selector ".material-symbols-outlined", text: /download/
    end
  end

  test "clicking export transitions button to generating state" do
    sign_in_and_visit deck_path(decks(:one))

    # Stub the job so the test doesn't actually generate a file
    GeneratePptxJob.stub(:perform_later, nil) do
      find("#export_button_#{decks(:one).id}").click_on("Export")
    end

    # After the Turbo Stream update the button should show a spinner or progress indicator
    assert_selector "#export_button_#{decks(:one).id} [data-controller='progress'], #export_button_#{decks(:one).id} [class*='animate']", wait: 5
  end

  # ── Auto-save indicator ───────────────────────────────────────────────────────

  test "auto-save indicator element is present in deck editor" do
    sign_in_and_visit deck_path(decks(:one))

    assert_selector "[data-auto-save-target='indicator']", wait: 5
  end
end
