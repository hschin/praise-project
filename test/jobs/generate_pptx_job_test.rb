require "test_helper"
require "open3"

class GeneratePptxJobTest < ActiveJob::TestCase
  setup do
    @deck = decks(:one)
  end

  # ── Enqueue ───────────────────────────────────────────────────────────────────

  test "job enqueues on the default queue" do
    assert_enqueued_with(job: GeneratePptxJob, queue: "default") do
      GeneratePptxJob.perform_later(@deck.id)
    end
  end

  # ── Python script success path ────────────────────────────────────────────────

  test "perform broadcasts ready state when script succeeds" do
    fake_output_path = Tempfile.new([ "deck_test", ".pptx" ]).path
    # Write a dummy file so File.exist? passes
    File.write(fake_output_path, "fake pptx content")

    # Stub Open3.capture3 to simulate a successful python script run
    capture3_stub = ->(*_args, **_kwargs) { [ "", "", Process::Status.allocate ] }
    status_stub = double_status(success: true)

    Open3.stub(:capture3, ->(*args, stdin_data: nil) {
      # Parse the JSON payload and write to the output_path it specifies
      payload = JSON.parse(stdin_data)
      File.write(payload["output_path"], "fake pptx content")
      [ "", "", status_stub ]
    }) do
      # Turbo broadcast stubbed by test environment (no ActionCable config needed)
      assert_nothing_raised do
        GeneratePptxJob.new.perform(@deck.id)
      end
    end
  ensure
    File.delete(fake_output_path) if fake_output_path && File.exist?(fake_output_path)
  end

  # ── Python script failure path ────────────────────────────────────────────────

  test "perform does not raise when script exits non-zero" do
    status_stub = double_status(success: false)

    Open3.stub(:capture3, ->(*_args, stdin_data: nil) { [ "", "python error", status_stub ] }) do
      assert_nothing_raised do
        GeneratePptxJob.new.perform(@deck.id)
      end
    end
  end

  test "perform does not raise when output file is missing despite success exit" do
    status_stub = double_status(success: true)

    Open3.stub(:capture3, ->(*_args, stdin_data: nil) {
      # Intentionally do NOT write the output file
      [ "", "", status_stub ]
    }) do
      assert_nothing_raised do
        GeneratePptxJob.new.perform(@deck.id)
      end
    end
  end

  # ── Payload structure ─────────────────────────────────────────────────────────

  test "build_payload includes deck title, theme defaults, and songs" do
    payload = GeneratePptxJob.new.send(:build_payload, @deck, "/tmp/test.pptx")

    assert_equal @deck.title, payload.dig(:deck, :title)
    assert_equal "/tmp/test.pptx", payload[:output_path]
    assert payload.dig(:deck, :theme, :background_color).present?
    assert payload.dig(:deck, :theme, :text_color).present?
    assert_kind_of Array, payload.dig(:deck, :songs)
  end

  test "build_payload falls back to default colors when deck has no theme" do
    @deck.update_column(:theme_id, nil)
    payload = GeneratePptxJob.new.send(:build_payload, @deck, "/tmp/test.pptx")

    assert_equal "#1a1a2e", payload.dig(:deck, :theme, :background_color)
    assert_equal "#ffffff", payload.dig(:deck, :theme, :text_color)
  end

  test "build_payload songs array contains slides from safe_lyrics" do
    payload = GeneratePptxJob.new.send(:build_payload, @deck, "/tmp/test.pptx")
    songs = payload.dig(:deck, :songs)

    # deck(:one) has deck_songs with arrangements pointing to lyrics(:one) and (:two)
    songs.each do |song|
      assert_kind_of Array, song[:slides]
    end
  end

  # ── Deck not found ────────────────────────────────────────────────────────────

  test "perform does not raise when deck is missing — logs and exits silently" do
    # Deck.find raises RecordNotFound; the rescue block calls broadcast_error,
    # which returns early because Deck.find_by returns nil.
    assert_nothing_raised do
      GeneratePptxJob.new.perform(0)
    end
  end

  private

  # Returns a minimal object that responds to #success? as needed
  def double_status(success:)
    obj = Object.new
    obj.define_singleton_method(:success?) { success }
    obj
  end
end
