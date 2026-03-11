require "test_helper"

class ImportSongJobTest < ActiveJob::TestCase
  FAKE_SECTIONS = [
    { "section_type" => "verse", "lines" => [
      { "chars" => ["宇","宙"], "pinyin" => ["yǔ","zhòu"] }
    ]}
  ].freeze

  # SONG-01: search path creates song with lyrics
  test "perform with title creates song and lyrics" do
    ClaudeLyricsService.stub(:call, { "unknown" => false, "sections" => FAKE_SECTIONS }) do
      ImportSongJob.new.perform("宇宙之光")
    end
    song = Song.find_by!(title: "宇宙之光")
    assert song.done?
    assert song.lyrics.any?
  end

  # SONG-04: manual paste path skips web search
  test "perform with raw_lyrics skips web search" do
    ClaudeLyricsService.stub(:call, { "unknown" => false, "sections" => FAKE_SECTIONS }) do
      ImportSongJob.new.perform("宇宙之光", raw_lyrics: "你好")
    end
    song = Song.find_by!(title: "宇宙之光")
    assert song.done?
  end

  # Unknown song broadcasts failed and does not create a Song record
  test "perform with unknown song does not create a song" do
    ClaudeLyricsService.stub(:call, { "unknown" => true, "sections" => [] }) do
      assert_no_difference("Song.count") do
        ImportSongJob.new.perform("xyzfake99")
      end
    end
  end
end
