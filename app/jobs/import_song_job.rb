class ImportSongJob < ApplicationJob
  queue_as :default

  STEP_SEARCH = "searching"
  STEP_CLAUDE = "generating"

  def perform(title, raw_lyrics: nil)
    stream_key = stream_for(title)
    broadcast_step(stream_key, raw_lyrics ? STEP_CLAUDE : STEP_SEARCH)

    result = ClaudeLyricsService.call(title: title, raw_lyrics: raw_lyrics)

    if result["unknown"]
      broadcast_failed(stream_key, title)
      return
    end

    song = Song.create!(title: title, import_status: "done")
    save_lyrics!(song, result["sections"])
    broadcast_done(stream_key, song)
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

  def broadcast_done(stream_key, song)
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "import_status",
      html: %(<div data-controller="redirect" data-redirect-url-value="#{Rails.application.routes.url_helpers.song_path(song)}"></div>)
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
