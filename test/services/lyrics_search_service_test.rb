require "test_helper"

class LyricsSearchServiceTest < ActiveSupport::TestCase
  test "call returns array of URLs for a title" do
    fake_results = {
      organic_results: [
        { link: "https://example.com/song1" },
        { link: "https://example.com/song2" }
      ]
    }

    mock_client = Minitest::Mock.new
    mock_client.expect(:search, fake_results, [Hash])

    SerpApi::Client.stub(:new, mock_client) do
      urls = LyricsSearchService.call("宇宙之光")
      assert_kind_of Array, urls
      assert urls.first.start_with?("http")
    end
  end

  test "call returns empty array when no organic results" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:search, { organic_results: nil }, [Hash])

    SerpApi::Client.stub(:new, mock_client) do
      urls = LyricsSearchService.call("NoResults")
      assert_equal [], urls
    end
  end
end
