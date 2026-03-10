class LyricsSearchService
  MAX_RESULTS = 3

  def self.call(title)
    new(title).call
  end

  def initialize(title)
    @title = title
  end

  def call
    client = SerpApi::Client.new(
      engine: "google",
      api_key: ENV.fetch("SERPAPI_KEY", nil)
    )
    results = client.search(q: "#{@title} 歌词 lyrics")
    (results[:organic_results] || [])
      .map { |r| r[:link] }
      .compact
      .first(MAX_RESULTS)
  rescue => e
    Rails.logger.error("[LyricsSearchService] #{e.class}: #{e.message}")
    []
  end
end
