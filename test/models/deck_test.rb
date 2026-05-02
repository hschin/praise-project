require "test_helper"

class DeckTest < ActiveSupport::TestCase
  # ── Validations ──────────────────────────────────────────────────────────────

  test "valid with title, date, and user" do
    deck = Deck.new(title: "Sunday Service", date: Date.today, user: users(:one))
    assert deck.valid?
  end

  test "invalid without title" do
    deck = Deck.new(title: "", date: Date.today, user: users(:one))
    assert_not deck.valid?
    assert_includes deck.errors[:title], "can't be blank"
  end

  test "invalid without date" do
    deck = Deck.new(title: "Sunday Service", date: nil, user: users(:one))
    assert_not deck.valid?
    assert_includes deck.errors[:date], "can't be blank"
  end

  test "lines_per_slide must be integer between 1 and 8" do
    deck = Deck.new(title: "T", date: Date.today, user: users(:one))

    [ 1, 4, 8 ].each do |n|
      deck.lines_per_slide = n
      assert deck.valid?, "Expected lines_per_slide=#{n} to be valid"
    end

    [ 0, 9, 1.5 ].each do |n|
      deck.lines_per_slide = n
      assert_not deck.valid?, "Expected lines_per_slide=#{n} to be invalid"
    end
  end

  # ── Associations ─────────────────────────────────────────────────────────────

  test "belongs to user" do
    assert_equal users(:one), decks(:one).user
  end

  test "has many deck_songs ordered by position" do
    deck = decks(:one)
    positions = deck.deck_songs.pluck(:position)
    assert_equal positions.sort, positions, "Expected deck_songs to be ordered by position"
  end

  test "destroying a deck destroys its deck_songs" do
    deck = decks(:one)
    deck_song_ids = deck.deck_songs.pluck(:id)
    deck.destroy
    deck_song_ids.each do |id|
      assert_nil DeckSong.find_by(id: id)
    end
  end

  test "theme association is optional" do
    deck = Deck.new(title: "No Theme", date: Date.today, user: users(:one), theme: nil)
    assert deck.valid?
  end

  # ── Songs through deck_songs ─────────────────────────────────────────────────

  test "songs are accessible through deck" do
    deck = decks(:one)
    assert deck.songs.count >= 1
    assert deck.songs.first.is_a?(Song)
  end
end
