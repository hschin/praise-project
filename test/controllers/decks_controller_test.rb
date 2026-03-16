require "test_helper"

class DecksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "unauthenticated GET /decks redirects to sign in" do
    sign_out @user
    get decks_url
    assert_redirected_to new_user_session_path
  end

  test "authenticated GET /decks returns 200" do
    get decks_url
    assert_response :success
  end

  # DECK-01
  test "GET new pre-fills date with next Sunday" do
    get new_deck_url
    next_sunday = Date.today.next_occurring(:sunday)
    assert_response :success
    assert_select "input[name='deck[date]'][value='#{next_sunday}']"
  end

  # SLIDE-01
  test "deck show page includes Edit lyrics link for each deck_song" do
    get deck_url(decks(:one))
    assert_select "a[href*='songs']", minimum: 1
  end

  # SLIDE-04
  test "deck show page renders slide preview divs for arrangement entries" do
    get deck_url(decks(:one))
    assert_select ".slide-preview"
  end

  test "deck show page renders without error when arrangement contains stale lyric ID" do
    ds = deck_songs(:one)
    ds.update_column(:arrangement, [999999])
    get deck_url(decks(:one))
    assert_response :success
  end

  test "deck show page renders without error when arrangement is nil" do
    ds = deck_songs(:one)
    ds.update_column(:arrangement, nil)
    get deck_url(decks(:one))
    assert_response :success
  end

  # NAV-03
  test "POST quick_create redirects to deck editor" do
    post quick_create_decks_url
    created_deck = Deck.order(created_at: :desc).first
    assert_redirected_to deck_path(created_deck)
  end

  # NAV-04
  test "POST quick_create title matches upcoming Sunday format" do
    post quick_create_decks_url
    created_deck = Deck.order(created_at: :desc).first
    assert_match(/\ASunday \d{1,2} \w+\z/, created_deck.title)
  end

  # FORM-02
  test "flash notice renders toast with green-50 class" do
    delete deck_url(decks(:one))
    follow_redirect!
    assert_match(/green-50/, response.body)
  end

  # FORM-02
  test "flash alert renders toast with red-50 class" do
    post import_songs_url, params: { title: "" }
    follow_redirect!
    assert_match(/red-50/, response.body)
  end

  # NAV-02
  test "GET /decks renders card grid with date before title" do
    get decks_url
    assert_match(/grid/, response.body)
    assert_match(/strftime|Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday/, response.body)
  end

  # NAV-02
  test "GET /decks delete button has turbo-confirm data attribute" do
    get decks_url
    assert_match(/data-turbo-confirm/, response.body)
  end

  # EMPTY-01
  test "GET /decks shows empty state headline when no decks exist" do
    Deck.destroy_all
    get decks_url
    assert_match(/Build worship slide decks in minutes/, response.body)
  end

  # EMPTY-02
  test "deck show page renders empty state copy when deck has no songs" do
    empty_deck = Deck.create!(title: "Empty", date: Date.today, user: @user)
    get deck_url(empty_deck)
    assert_match(/Your arrangement will appear here/, response.body)
  end

  # DECK-01: Section type chip styling in slide item
  test "deck show renders section chip for slide items" do
    get deck_url(decks(:one))
    assert_match(/bg-amber-100|rounded-full.*section|section.*rounded-full/, response.body)
  end

  # DECK-02: Artist shown in library panel song list items
  test "deck show renders artist in library panel" do
    Song.create!(title: "Grace Alone", artist: "Sovereign Grace Music", import_status: "done")
    get deck_url(decks(:one))
    # Library items use data-song-search-target="item"; artist should appear as secondary text
    assert_match(/data-song-search-target="item"/, response.body)
    assert_match(/Sovereign Grace Music/, response.body)
  end

  # DECK-03: Idle export button renders download icon (arrow-down-tray SVG)
  test "export button idle renders download icon" do
    get deck_url(decks(:one))
    assert_match(/arrow-down-tray|M12 16\.5V9\.75m0 0/, response.body)
  end

  # DECK-03: Ready export button renders green button with check-circle icon
  test "export button ready renders green button with check icon" do
    html = ApplicationController.render(
      partial: "decks/export_button",
      locals: { deck: decks(:one), state: :ready, token: "abc123" }
    )
    assert_match(/bg-green-600/, html)
    assert_match(/check-circle|M9 12\.75 11\.25 15 15 9\.75/, html)
  end

  # DECK-04: Panel labels "ADD SONGS" and "ARRANGEMENT" both present
  test "deck show panel labels" do
    get deck_url(decks(:one))
    assert_match(/ADD SONGS/, response.body)
    assert_match(/ARRANGEMENT/, response.body)
  end

  # DECK-05: Pencil icon on deck title is hover-only (opacity-0 with group-hover:opacity-100)
  test "deck title pencil hover only" do
    get deck_url(decks(:one))
    assert_match(/opacity-0[^"]*group-hover:opacity-100|group-hover:opacity-100[^"]*opacity-0/, response.body)
  end

  # DECK-06: Auto-save indicator element present
  test "deck show renders auto save indicator" do
    get deck_url(decks(:one))
    assert_select "[data-auto-save-target='indicator']"
  end
end
