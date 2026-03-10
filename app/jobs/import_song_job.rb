class ImportSongJob < ApplicationJob
  queue_as :default

  STEP_SEARCH = "Searching web..."
  STEP_SCRAPE = "Fetching lyrics..."
  STEP_CLAUDE = "Generating pinyin..."
  STEP_DONE   = "Done"

  def perform(song_id, raw_lyrics: nil)
    song = Song.find(song_id)
    song.update!(import_status: "processing", import_step: raw_lyrics ? STEP_CLAUDE : STEP_SEARCH)
    broadcast_processing(song)

    raw_text = raw_lyrics || fetch_raw_text(song)
    result   = call_claude(song, raw_text)

    if result["unknown"] && raw_lyrics.nil?
      fail_song!(song)
      return
    end

    save_lyrics!(song, result["sections"])
    song.update!(import_status: "done", import_step: STEP_DONE)
    Turbo::StreamsChannel.broadcast_replace_to(
      song,
      target: "song_status_#{song.id}",
      partial: "songs/lyrics",
      locals: { song: song }
    )
  rescue => e
    Rails.logger.error("[ImportSongJob] song_id=#{song_id} #{e.class}: #{e.message}")
    fail_song!(Song.find_by(id: song_id))
  end

  private

  def fetch_raw_text(song)
    broadcast_step(song, STEP_SEARCH)
    urls = LyricsSearchService.call(song.title)
    return nil if urls.empty?

    broadcast_step(song, STEP_SCRAPE)
    urls.each do |url|
      text = LyricsScraperService.call(url)
      return text if text.present?
    end
    nil
  end

  def call_claude(song, raw_text)
    broadcast_step(song, STEP_CLAUDE)
    ClaudeLyricsService.call(title: song.title, raw_lyrics: raw_text)
  end

  def save_lyrics!(song, sections)
    song.lyrics.destroy_all
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

  def broadcast_step(song, step)
    song.update_column(:import_step, step)
    Turbo::StreamsChannel.broadcast_replace_to(
      song,
      target: "song_status_#{song.id}",
      partial: "songs/processing",
      locals: { song: song }
    )
  end

  def broadcast_processing(song)
    Turbo::StreamsChannel.broadcast_replace_to(
      song,
      target: "song_status_#{song.id}",
      partial: "songs/processing",
      locals: { song: song }
    )
  end

  def fail_song!(song)
    return unless song
    song.update!(import_status: "failed", import_step: nil)
    Turbo::StreamsChannel.broadcast_replace_to(
      song,
      target: "song_status_#{song.id}",
      partial: "songs/failed",
      locals: { song: song }
    )
  end
end
