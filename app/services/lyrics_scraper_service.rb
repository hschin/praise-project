class LyricsScraperService
  TIMEOUT_SECONDS = 10

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url
  end

  def call
    conn = Faraday.new(request: { timeout: TIMEOUT_SECONDS }) do |f|
      f.headers["User-Agent"] = "Mozilla/5.0 (compatible; PraiseProject/1.0)"
    end

    response = conn.get(@url)
    return nil unless response.success?

    doc = Nokogiri::HTML(response.body)
    doc.css("script, style, nav, header, footer, aside").remove
    text = doc.css("body").text.strip
    text.empty? ? nil : text
  rescue Faraday::Error => e
    Rails.logger.error("[LyricsScraperService] #{e.class}: #{e.message} (#{@url})")
    nil
  end
end
