class ClaudeLyricsService
  MODEL = "claude-sonnet-4-5-20250929"

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a Chinese worship music expert.
    When given a song title (and optionally raw lyrics), return the complete
    lyrics in Simplified Chinese with tone-marked pinyin (e.g. nǐ hǎo, not ni3 hao3)
    structured into labeled sections.
    Always convert Traditional Chinese characters to Simplified Chinese in your output,
    even if the input or source lyrics are in Traditional Chinese.

    For each line, provide chars as an array of individual characters and pinyin
    as a parallel array of tone-marked syllables. One pinyin token per character.

    Example for line "你好":
      chars: ["你","好"], pinyin: ["nǐ","hǎo"]

    Always label section_type in English (e.g. "Verse 1", "Verse 2", "Chorus", "Bridge", "Pre-Chorus", "Intro", "Outro", "Tag").

    If raw lyrics are not provided, use web search to find the complete lyrics before structuring them.
    If you cannot find the song after searching, return sections: [] and unknown: true.
    Never fabricate lyrics you do not know.

    Respond with raw JSON only — no markdown code fences, no explanation text.
  PROMPT

  WEB_SEARCH_TOOL = { type: "web_search_20250305", name: "web_search" }.freeze

  def self.call(title:, raw_lyrics: nil)
    new(title: title, raw_lyrics: raw_lyrics).call
  end

  def initialize(title:, raw_lyrics: nil)
    @title = title
    @raw_lyrics = raw_lyrics
  end

  def call
    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY", nil))
    params = {
      model: MODEL,
      max_tokens: 4096,
      system: SYSTEM_PROMPT,
      messages: [
        { role: "user", content: user_message },
        { role: "assistant", content: "{" }
      ]
    }
    params[:tools] = [ WEB_SEARCH_TOOL ] if @raw_lyrics.blank?
    response = client.messages.create(**params)
    text_block = response.content.reverse.find { |b| b.type == :text }
    JSON.parse("{" + text_block.text)
  end

  private

  def user_message
    if @raw_lyrics.present?
      "Song title: #{@title}\n\nRaw lyrics to structure:\n#{@raw_lyrics}"
    else
      "Song title: #{@title}\n\nSearch the web for the complete lyrics for this song, then return them structured with pinyin."
    end
  end
end
