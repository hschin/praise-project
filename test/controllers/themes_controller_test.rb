require "test_helper"

class ThemesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @deck = decks(:one)
    sign_in @user
  end

  test "POST /decks/:deck_id/themes creates custom theme and assigns to deck" do
    assert_difference "Theme.count", 1 do
      post deck_themes_path(@deck), params: {
        theme: { name: "My Theme", source: "custom", background_color: "#111111", text_color: "#eeeeee", font_size: "large" }
      }
    end
    assert_redirected_to deck_path(@deck)
    assert_equal Theme.last.id, @deck.reload.theme_id
  end

  test "POST /decks/:deck_id/themes with background image attaches file" do
    file = Rack::Test::UploadedFile.new(
      StringIO.new("\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xFF\xD9"),
      "image/jpeg",
      original_filename: "test.jpg"
    )
    assert_difference "Theme.count", 1 do
      post deck_themes_path(@deck), params: {
        theme: { name: "Image Theme", source: "custom", background_image: file }
      }
    end
    assert Theme.last.background_image.attached?
  end
end
