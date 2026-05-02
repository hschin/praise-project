require "test_helper"

class ClaudeLyricsServiceTest < ActiveSupport::TestCase
  FAKE_SECTIONS = [
    {
      "section_type" => "verse",
      "lines" => [
        { "chars" => [ "宇", "宙" ], "pinyin" => [ "yǔ", "zhòu" ] }
      ]
    }
  ].freeze

  # .import is the public class-level entry point used by ImportSongJob
  test "import returns structured sections for a known song" do
    fake_response = { "unknown" => false, "sections" => FAKE_SECTIONS }

    ClaudeLyricsService.stub(:import, fake_response) do
      result = ClaudeLyricsService.import(title: "宇宙之光", artist: "讚美之泉")
      assert_equal false, result["unknown"]
      assert_equal 1, result["sections"].length
    end
  end

  test "import returns unknown: true when song is not known" do
    fake_response = { "unknown" => true, "sections" => [] }

    ClaudeLyricsService.stub(:import, fake_response) do
      result = ClaudeLyricsService.import(title: "ObscureSong12345", artist: "Unknown")
      assert_equal true, result["unknown"]
      assert_empty result["sections"]
    end
  end

  test "import requires artist keyword argument" do
    assert_raises(ArgumentError) do
      ClaudeLyricsService.import(title: "宇宙之光")
    end
  end

  test "search returns a result hash" do
    fake_response = { "candidates" => [] }

    ClaudeLyricsService.stub(:search, fake_response) do
      result = ClaudeLyricsService.search(title: "宇宙之光")
      assert_kind_of Hash, result
    end
  end
end
