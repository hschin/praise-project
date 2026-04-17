class ImportSongJob < ApplicationJob
  queue_as :default

  STEP_SEARCH = "searching"
  STEP_CLAUDE = "generating"

  def perform(title, artist: nil, raw_lyrics: nil, deck_id: nil, metadata: {})
    stream_key = stream_for(title)
    broadcast_step(stream_key, STEP_CLAUDE)

    result = ClaudeLyricsService.import(title: title, artist: artist, raw_lyrics: raw_lyrics)

    if result["unknown"]
      broadcast_failed(stream_key, title)
      return
    end

    song_attrs = { title: title, artist: artist, import_status: "done" }
      .merge(metadata.slice("english_title", "default_key", "ccli_number").transform_keys(&:to_sym))
    song = Song.create!(song_attrs)
    save_lyrics!(song, result["sections"])

    if deck_id.present? && (deck = Deck.find_by(id: deck_id))
      deck.deck_songs.create!(
        song: song,
        position: deck.deck_songs.count + 1,
        arrangement: song.lyrics.order(:position).pluck(:id).map(&:to_i)
      )
      redirect_url = Rails.application.routes.url_helpers.deck_path(deck_id)
    else
      redirect_url = Rails.application.routes.url_helpers.song_path(song)
    end

    broadcast_done(stream_key, redirect_url)
  rescue => e
    Rails.logger.error("[ImportSongJob] title=#{title} #{e.class}: #{e.message}")
    broadcast_failed(stream_for(title), title)
  end

  private

  def stream_for(title)
    "song_import_#{title.parameterize}"
  end

  def broadcast_step(stream_key, step)
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "import_status",
      partial: "songs/processing",
      locals: { step: step }
    )
  end

  def broadcast_done(stream_key, redirect_url)
    # Briefly show both steps complete before redirecting
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "import_status",
      partial: "songs/processing",
      locals: { step: "done" }
    )
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "import_status",
      html: %(<div data-controller="redirect" data-redirect-url-value="#{redirect_url}"></div>)
    )
  end

  def broadcast_failed(stream_key, title)
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "import_status",
      partial: "songs/failed",
      locals: { title: title }
    )
  end

  def save_lyrics!(song, sections)
    sections.each_with_index do |section, idx|
      lines_content = section["lines"].map { |l| l["chars"].join }.join("\n")
      lines_pinyin  = section["lines"].map { |l| l["pinyin"].join(" ") }.join("\n")
      song.lyrics.create!(
        section_type: section["section_type"],
        position:     idx + 1,
        content:      lines_content,
        pinyin:       lines_pinyin
      )
    end
  end
end
