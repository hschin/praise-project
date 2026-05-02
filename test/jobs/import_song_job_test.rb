require "test_helper"

class ImportSongJobTest < ActiveJob::TestCase
  FAKE_SECTIONS = [
    { "section_type" => "verse", "lines" => [
      { "chars" => [ "宇", "宙" ], "pinyin" => [ "yǔ", "zhòu" ] }
    ] }
  ].freeze

  # SONG-01: creates song with lyrics when Claude returns known result
  test "perform with title creates song and lyrics" do
    ClaudeLyricsService.stub(:import, { "unknown" => false, "sections" => FAKE_SECTIONS }) do
      ImportSongJob.new.perform("宇宙之光", artist: nil)
    end
    song = Song.find_by!(title: "宇宙之光")
    assert song.done?
    assert song.lyrics.any?
  end

  # SONG-04: manual paste path also uses .import (raw_lyrics forwarded to service)
  test "perform with raw_lyrics creates song and lyrics" do
    ClaudeLyricsService.stub(:import, { "unknown" => false, "sections" => FAKE_SECTIONS }) do
      ImportSongJob.new.perform("宇宙之光", artist: nil, raw_lyrics: "你好")
    end
    song = Song.find_by!(title: "宇宙之光")
    assert song.done?
  end

  # Unknown song broadcasts failed and does not create a Song record
  test "perform with unknown song does not create a song" do
    ClaudeLyricsService.stub(:import, { "unknown" => true, "sections" => [] }) do
      assert_no_difference("Song.count") do
        ImportSongJob.new.perform("xyzfake99", artist: nil)
      end
    end
  end
end
