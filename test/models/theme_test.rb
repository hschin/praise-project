require "test_helper"

class ThemeTest < ActiveSupport::TestCase
  test "valid with name and source" do
    theme = Theme.new(name: "Test", source: "custom")
    assert theme.valid?
  end

  test "invalid without name" do
    theme = Theme.new(source: "custom")
    assert_not theme.valid?
    assert_includes theme.errors[:name], "can't be blank"
  end

  test "invalid with unknown source" do
    theme = Theme.new(name: "Test", source: "unknown")
    assert_not theme.valid?
  end

  test "FONT_SIZE_PRESETS has small medium large" do
    assert_equal 28, Theme::FONT_SIZE_PRESETS["small"]
    assert_equal 36, Theme::FONT_SIZE_PRESETS["medium"]
    assert_equal 48, Theme::FONT_SIZE_PRESETS["large"]
  end

  test "background_image attachment" do
    theme = themes(:custom_theme)
    assert_respond_to theme, :background_image
  end

  test "background_image not attached by default" do
    theme = themes(:custom_theme)
    assert_not theme.background_image.attached?
  end

  test "falls back to background_color when no image attached" do
    theme = themes(:custom_theme)
    assert_equal "#1a3a5c", theme.background_color
    assert_not theme.background_image.attached?
  end
end
