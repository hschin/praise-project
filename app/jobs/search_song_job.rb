class SearchSongJob < ApplicationJob
  queue_as :default

  def perform(title, artist: nil, raw_lyrics: nil, deck_id: nil)
    stream_key = stream_for(title, artist)

    # If raw lyrics provided, skip search - go straight to single candidate
    if raw_lyrics.present?
      candidates = [{
        "title" => title,
        "artist" => artist || "Unknown",
        "snippet" => raw_lyrics.lines.first(2).join.strip
      }]
      broadcast_candidates(stream_key, candidates, raw_lyrics)
      return
    end

    # Search for candidates via Claude
    result = ClaudeLyricsService.search(title: title, artist: artist)
    candidates = result["candidates"] || []

    if candidates.empty?
      broadcast_failed(stream_key, title)
      return
    end

    broadcast_candidates(stream_key, candidates, raw_lyrics)
  rescue => e
    Rails.logger.error("[SearchSongJob] title=#{title} #{e.class}: #{e.message}")
    broadcast_failed(stream_for(title, artist), title)
  end

  private

  def stream_for(title, artist)
    key = artist.present? ? "#{title}_#{artist}" : title
    "song_search_#{key.parameterize}"
  end

  def broadcast_candidates(stream_key, candidates, raw_lyrics)
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "search_results",
      partial: "songs/candidates",
      locals: { 
        candidates: candidates, 
        raw_lyrics: raw_lyrics,
        authenticity_token: nil  # Background job has no session - we'll handle this differently
      }
    )
  end

  def broadcast_failed(stream_key, title)
    Turbo::StreamsChannel.broadcast_update_to(
      stream_key,
      target: "search_results",
      partial: "songs/search_failed",
      locals: { title: title }
    )
  end
end
