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
end
