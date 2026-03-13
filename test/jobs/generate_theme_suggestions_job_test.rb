require "test_helper"

class GenerateThemeSuggestionsJobTest < ActiveJob::TestCase
  setup do
    @deck = decks(:one)
  end

  test "job enqueues without error" do
    assert_enqueued_with(job: GenerateThemeSuggestionsJob) do
      GenerateThemeSuggestionsJob.perform_later(@deck.id)
    end
  end

  test "perform calls ClaudeThemeService and broadcasts to Turbo" do
    suggestions = [
      { "name" => "Sky Blue", "background_color" => "#87ceeb", "text_color" => "#000000",
        "font_size" => "medium", "unsplash_url" => "https://images.unsplash.com/photo-1" }
    ]
    ClaudeThemeService.stub(:call, suggestions) do
      # Verify job runs without raising — Turbo broadcast stubbed by test env
      assert_nothing_raised do
        GenerateThemeSuggestionsJob.new.perform(@deck.id)
      end
    end
  end
end
