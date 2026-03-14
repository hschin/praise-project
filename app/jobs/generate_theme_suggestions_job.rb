require "net/http"
require "json"

class GenerateThemeSuggestionsJob < ApplicationJob
  queue_as :default

  def perform(deck_id)
    deck = Deck.find(deck_id)
    suggestions = ClaudeThemeService.call(deck: deck)

    if suggestions.empty?
      broadcast_error(deck_id, "No suggestions returned from Claude")
      return
    end

    suggestions_with_photos = suggestions.map do |s|
      photo_data = fetch_unsplash_photo(s["unsplash_query"])
      s.merge(
        "unsplash_url"              => photo_data[:url],
        "unsplash_attribution_name" => photo_data[:name],
        "unsplash_attribution_url"  => photo_data[:profile_url]
      )
    end

    Turbo::StreamsChannel.broadcast_update_to(
      "deck_themes_#{deck_id}",
      target: "theme_suggestions",
      partial: "themes/suggestion_row",
      locals: { suggestions: suggestions_with_photos, deck: deck }
    )
  rescue => e
    Rails.logger.error("[GenerateThemeSuggestionsJob] deck_id=#{deck_id} #{e.class}: #{e.message}")
    broadcast_error(deck_id, e.message)
  end

  private

  def fetch_unsplash_photo(query)
    return { url: nil, name: nil, profile_url: nil } if query.blank?
    access_key = ENV.fetch("UNSPLASH_ACCESS_KEY", nil)
    return { url: nil, name: nil, profile_url: nil } if access_key.blank?

    uri = URI("https://api.unsplash.com/search/photos")
    uri.query = URI.encode_www_form(query: query, per_page: 1, orientation: "landscape")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Client-ID #{access_key}"

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    result = JSON.parse(response.body)
    {
      url:         result.dig("results", 0, "urls", "regular"),
      name:        result.dig("results", 0, "user", "name"),
      profile_url: result.dig("results", 0, "user", "links", "html")
    }
  rescue => e
    Rails.logger.error("[GenerateThemeSuggestionsJob] Unsplash fetch failed: #{e.message}")
    { url: nil, name: nil, profile_url: nil }
  end

  def broadcast_error(deck_id, message = nil)
    text = message ? "Could not generate suggestions: #{message}" : "Could not generate suggestions. Please try again."
    Turbo::StreamsChannel.broadcast_update_to(
      "deck_themes_#{deck_id}",
      target: "theme_suggestions",
      html: %(<p class="text-xs text-red-400 py-2">#{ERB::Util.html_escape(text)}</p>)
    )
  end
end
