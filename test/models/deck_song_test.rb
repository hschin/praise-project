require "test_helper"

class DeckSongTest < ActiveSupport::TestCase
  # DECK-02: arrangement initialized with integer lyric IDs
  test "before_save casts arrangement string IDs to integers" do
    ds = deck_songs(:one)
    ds.arrangement = ds.arrangement.map(&:to_s)  # force strings
    ds.save!
    assert ds.arrangement.all? { |id| id.is_a?(Integer) },
           "Expected all arrangement IDs to be Integer after save"
  end

  test "arrangement can be nil" do
    ds = deck_songs(:two)
    ds.arrangement = nil
    assert ds.save, "DeckSong with nil arrangement should be valid"
  end

  # safe_lyrics helper
  test "safe_lyrics returns empty array when arrangement is nil" do
    ds = deck_songs(:two)
    ds.update_column(:arrangement, nil)
    assert_equal [], ds.safe_lyrics
  end

  test "safe_lyrics returns empty array when arrangement is empty" do
    ds = deck_songs(:one)
    ds.update_column(:arrangement, [])
    assert_equal [], ds.safe_lyrics
  end

  test "safe_lyrics returns Lyric objects for valid arrangement IDs" do
    ds = deck_songs(:one)
    result = ds.safe_lyrics
    assert result.all? { |l| l.is_a?(Lyric) },
           "Expected safe_lyrics to return Lyric instances"
    assert_equal ds.arrangement.length, result.length
  end

  test "safe_lyrics skips stale lyric IDs without raising" do
    ds = deck_songs(:one)
    stale_id = 999999
    ds.update_column(:arrangement, [ stale_id ] + ds.arrangement)
    result = ds.safe_lyrics
    assert_not_includes result.map(&:id), stale_id
    assert_equal ds.arrangement.length - 1, result.length
  end

  test "safe_lyrics preserves arrangement order" do
    ds = deck_songs(:one)
    next if ds.arrangement.length < 2
    result_ids = ds.safe_lyrics.map(&:id)
    assert_equal ds.arrangement.filter_map { |id| Lyric.find_by(id: id)&.id }, result_ids
  end
end
