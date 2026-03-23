require "test_helper"

class DeckSongsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user  = users(:one)
    @deck  = decks(:one)
    @song  = songs(:one)
    sign_in @user
  end

  # DECK-02
  test "POST create adds song to deck with arrangement initialized" do
    assert_difference "DeckSong.count", 1 do
      post deck_deck_songs_path(@deck), params: { song_id: @song.id }
    end
    ds = DeckSong.order(:created_at).last
    assert_not_nil ds.arrangement
    assert_equal @song.lyrics.order(:position).pluck(:id), ds.arrangement
  end

  test "arrangement IDs are integers not strings" do
    post deck_deck_songs_path(@deck), params: { song_id: @song.id }
    ds = DeckSong.order(:created_at).last
    assert ds.arrangement.all? { |id| id.is_a?(Integer) }, "Expected integer IDs"
  end

  # DECK-03
  test "PATCH reorder changes deck_song positions from ordered ID array" do
    ds1 = deck_songs(:one)   # position 1
    ds2 = deck_songs(:three) # position 2, same deck
    patch reorder_deck_deck_song_path(@deck, ds1),
          params: { order: [ ds2.id, ds1.id ] },
          as: :json
    assert_response :success
    assert_equal 1, ds2.reload.position
    assert_equal 2, ds1.reload.position
  end

  # DECK-04
  test "DELETE destroy removes deck_song without deleting song" do
    ds = deck_songs(:one)
    assert_difference "DeckSong.count", -1 do
      assert_no_difference "Song.count" do
        delete deck_deck_song_path(@deck, ds)
      end
    end
    assert_redirected_to deck_path(@deck)
  end

  # SLIDE-02
  test "PATCH update_arrangement reorders lyric IDs" do
    ds = deck_songs(:one)
    original = ds.arrangement.dup
    new_order = original.reverse
    patch update_arrangement_deck_deck_song_path(@deck, ds),
          params: { arrangement: new_order }, as: :json
    assert_response :success
    assert_equal new_order, ds.reload.arrangement
  end

  # SLIDE-03
  test "PATCH update_arrangement with index removed removes lyric from arrangement" do
    ds = deck_songs(:one)
    assert ds.arrangement.length >= 2, "Need at least 2 entries"
    new_arr = ds.arrangement.drop(1)
    patch update_arrangement_deck_deck_song_path(@deck, ds),
          params: { arrangement: new_arr }, as: :json
    assert_response :success
    assert_equal new_arr, ds.reload.arrangement
  end

  # SLIDE-05
  test "PATCH update_arrangement with duplicate appends repeat" do
    ds = deck_songs(:one)
    chorus_id = ds.arrangement.first
    new_arr = ds.arrangement + [chorus_id]
    patch update_arrangement_deck_deck_song_path(@deck, ds),
          params: { arrangement: new_arr }, as: :json
    assert_response :success
    assert_equal new_arr, ds.reload.arrangement
    assert_equal 2, ds.reload.arrangement.count(chorus_id)
  end
end
