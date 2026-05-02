require "test_helper"

class SongTest < ActiveSupport::TestCase
  # ── Validations ──────────────────────────────────────────────────────────────

  test "valid with title" do
    song = Song.new(title: "Grace Alone", import_status: "pending")
    assert song.valid?
  end

  test "invalid without title" do
    song = Song.new(title: "", import_status: "pending")
    assert_not song.valid?
    assert_includes song.errors[:title], "can't be blank"
  end

  # ── Enum: import_status ───────────────────────────────────────────────────────

  test "import_status defaults to pending on new record" do
    song = Song.create!(title: "New Song")
    assert_equal "pending", song.import_status
  end

  test "import_status transitions to done" do
    song = songs(:one)
    song.update!(import_status: "done")
    assert song.done?
  end

  test "import_status transitions to failed" do
    song = songs(:one)
    song.update!(import_status: "failed")
    assert song.failed?
  end

  test "import_status transitions to processing" do
    song = songs(:one)
    song.update!(import_status: "processing")
    assert song.processing?
  end

  test "invalid import_status raises ArgumentError" do
    assert_raises(ArgumentError) { songs(:one).update!(import_status: "unknown") }
  end

  # ── Associations ─────────────────────────────────────────────────────────────

  test "has many lyrics ordered by position" do
    song = songs(:one)
    # fixtures one/two have positions 1 and 2
    assert_equal [ 1, 2 ], song.lyrics.pluck(:position)
  end

  test "destroying a song destroys its lyrics" do
    song = songs(:one)
    lyric_ids = song.lyrics.pluck(:id)
    song.destroy
    lyric_ids.each do |id|
      assert_nil Lyric.find_by(id: id)
    end
  end

  test "destroying a song destroys its deck_songs" do
    song = songs(:one)
    deck_song_ids = song.deck_songs.pluck(:id)
    song.destroy
    deck_song_ids.each do |id|
      assert_nil DeckSong.find_by(id: id)
    end
  end

  # ── Query patterns ───────────────────────────────────────────────────────────

  test "can scope to done songs" do
    Song.create!(title: "Done Song", import_status: "done")
    Song.create!(title: "Pending Song", import_status: "pending")
    done_titles = Song.where(import_status: "done").pluck(:title)
    assert_includes done_titles, "Done Song"
    assert_not_includes done_titles, "Pending Song"
  end
end
