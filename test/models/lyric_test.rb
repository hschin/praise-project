require "test_helper"

class LyricTest < ActiveSupport::TestCase
  # SONG-02: section_type must be present
  test "invalid without section_type" do
    lyric = Lyric.new(position: 1, content: "你好")
    assert_not lyric.valid?
    assert_includes lyric.errors[:section_type], "can't be blank"
  end

  # SONG-03: pinyin field exists and can be stored
  test "valid with pinyin" do
    lyric = lyrics(:one)
    assert_not_nil lyric.pinyin
    assert lyric.valid?
  end
end
