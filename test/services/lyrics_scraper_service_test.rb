require "test_helper"

class LyricsScraperServiceTest < ActiveSupport::TestCase
  test "call returns text content from HTML page" do
    html = "<html><body><p>你好世界</p></body></html>"
    fake_response = Minitest::Mock.new
    fake_response.expect(:success?, true)
    fake_response.expect(:body, html)

    mock_conn = Minitest::Mock.new
    mock_conn.expect(:get, fake_response, [String])

    Faraday.stub(:new, mock_conn) do
      result = LyricsScraperService.call("https://example.com/song")
      assert_includes result, "你好世界"
    end
  end

  test "call returns nil on Faraday error" do
    Faraday.stub(:new, ->(_opts, &_block) {
      raise Faraday::Error, "connection failed"
    }) do
      result = LyricsScraperService.call("https://example.com/song")
      assert_nil result
    end
  end
end
