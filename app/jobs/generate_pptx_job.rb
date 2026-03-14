require "open3"
require "json"
require "base64"
require "tempfile"

class GeneratePptxJob < ApplicationJob
  queue_as :default

  PYTHON_SCRIPT = Rails.root.join("lib", "pptx_generator", "generate.py").to_s

  def perform(deck_id)
    deck = Deck.find(deck_id)
    output_path = File.join(Dir.tmpdir, "deck_#{deck_id}_#{Time.now.to_i}.pptx")

    payload = build_payload(deck, output_path)
    stdout, stderr, status = Open3.capture3("python3", PYTHON_SCRIPT, stdin_data: payload.to_json)

    unless status.success?
      Rails.logger.error("[GeneratePptxJob] deck_id=#{deck_id} script failed: #{stderr}")
      broadcast_error(deck_id, "PPTX generation failed. Please try again.")
      return
    end

    unless File.exist?(output_path)
      Rails.logger.error("[GeneratePptxJob] deck_id=#{deck_id} output file missing after success exit")
      broadcast_error(deck_id, "PPTX file not found after generation.")
      return
    end

    # Store the temp path in a short-lived Rails.cache entry keyed by a token,
    # then serve via a dedicated download action on DecksController.
    token = SecureRandom.urlsafe_base64(24)
    Rails.cache.write("pptx_export_#{token}", output_path, expires_in: 10.minutes)

    deck_obj = Deck.find(deck_id)
    Turbo::StreamsChannel.broadcast_update_to(
      "deck_export_#{deck_id}",
      target: "export_button_#{deck_id}",
      partial: "decks/export_button",
      locals: { deck: deck_obj, state: :ready, token: token }
    )
  rescue => e
    Rails.logger.error("[GeneratePptxJob] deck_id=#{deck_id} #{e.class}: #{e.message}")
    broadcast_error(deck_id, e.message)
  end

  private

  def build_payload(deck, output_path)
    theme = deck.theme
    bg_image_b64 = nil
    if theme&.background_image&.attached?
      bg_image_b64 = Base64.strict_encode64(theme.background_image.download)
    end

    songs = deck.deck_songs.map do |ds|
      slides = ds.safe_lyrics.map do |lyric|
        { section_type: lyric.section_type, content: lyric.content.to_s, pinyin: lyric.pinyin.to_s }
      end
      { title: ds.song.title, slides: slides }
    end

    {
      deck: {
        title: deck.title,
        theme: {
          background_color: theme&.background_color.presence || "#1a1a2e",
          text_color:       theme&.text_color.presence || "#ffffff",
          font_size:        theme&.font_size.presence || "medium",
          background_image_base64: bg_image_b64
        },
        songs: songs
      },
      output_path: output_path
    }
  end

  def broadcast_error(deck_id, message)
    deck = Deck.find_by(id: deck_id)
    Turbo::StreamsChannel.broadcast_update_to(
      "deck_export_#{deck_id}",
      target: "export_button_#{deck_id}",
      partial: "decks/export_button",
      locals: { deck: deck, state: :error, token: nil, error_message: message }
    )
  end
end
