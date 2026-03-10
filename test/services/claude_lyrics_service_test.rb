require "test_helper"

class ClaudeLyricsServiceTest < ActiveSupport::TestCase
  test "call returns structured sections for a known song" do
    fake_response = {
      "unknown" => false,
      "sections" => [
        {
          "section_type" => "verse",
          "lines" => [
            { "chars" => ["宇","宙"], "pinyin" => ["yǔ","zhòu"] }
          ]
        }
      ]
    }

    mock_client = Minitest::Mock.new
    mock_messages = Minitest::Mock.new
    mock_response = Minitest::Mock.new
    mock_content = Minitest::Mock.new

    mock_content.expect(:text, JSON.generate(fake_response))
    mock_response.expect(:content, [mock_content])
    mock_messages.expect(:create, mock_response, [Hash])
    mock_client.expect(:messages, mock_messages)

    Anthropic::Client.stub(:new, mock_client) do
      result = ClaudeLyricsService.call(title: "宇宙之光")
      assert_equal false, result["unknown"]
      assert_equal 1, result["sections"].length
    end
  end

  test "call returns unknown: true when song not known" do
    fake_response = { "unknown" => true, "sections" => [] }

    mock_client = Minitest::Mock.new
    mock_messages = Minitest::Mock.new
    mock_response = Minitest::Mock.new
    mock_content = Minitest::Mock.new

    mock_content.expect(:text, JSON.generate(fake_response))
    mock_response.expect(:content, [mock_content])
    mock_messages.expect(:create, mock_response, [Hash])
    mock_client.expect(:messages, mock_messages)

    Anthropic::Client.stub(:new, mock_client) do
      result = ClaudeLyricsService.call(title: "ObscureSong12345")
      assert_equal true, result["unknown"]
    end
  end
end
