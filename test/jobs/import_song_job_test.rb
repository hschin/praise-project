require "test_helper"

class ImportSongJobTest < ActiveJob::TestCase
  setup do
    @song = songs(:one)
  end

  # SONG-01: search path
  test "perform with title enqueues and creates lyrics" do
    ClaudeLyricsService.stub(:call, { "unknown" => false, "sections" => [
      { "section_type" => "verse", "lines" => [
        { "chars" => ["宇","宙"], "pinyin" => ["yǔ","zhòu"] }
      ]}
    ]}) do
      ImportSongJob.new.perform(@song.id)
    end
    @song.reload
    assert @song.done?
    assert @song.lyrics.any?
  end

  # SONG-04: manual paste path skips search/scrape
  test "perform with raw_lyrics skips search and scrape" do
    LyricsSearchService.stub(:call, -> (_title) { raise "should not be called" }) do
      ClaudeLyricsService.stub(:call, { "unknown" => false, "sections" => [
        { "section_type" => "verse", "lines" => [
          { "chars" => ["你","好"], "pinyin" => ["nǐ","hǎo"] }
        ]}
      ]}) do
        ImportSongJob.new.perform(@song.id, raw_lyrics: "你好")
      end
    end
    @song.reload
    assert @song.done?
  end

  # Failed import replaced by manual paste (locked decision)
  test "perform with raw_lyrics on failed song replaces lyrics in place" do
    @song.update!(import_status: "failed")
    ClaudeLyricsService.stub(:call, { "unknown" => false, "sections" => [
      { "section_type" => "chorus", "lines" => [
        { "chars" => ["讚","美"], "pinyin" => ["zàn","měi"] }
      ]}
    ]}) do
      ImportSongJob.new.perform(@song.id, raw_lyrics: "讚美")
    end
    @song.reload
    assert @song.done?
    assert_equal 1, @song.lyrics.count
  end
end
