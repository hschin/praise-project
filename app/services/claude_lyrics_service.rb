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
  PROMPT

  WEB_SEARCH_TOOL = { type: "web_search_20250305", name: "web_search" }.freeze

  OUTPUT_SCHEMA = {
    type: "object",
    properties: {
      unknown: { type: "boolean" },
      sections: {
        type: "array",
        items: {
          type: "object",
          properties: {
            section_type: { type: "string" },
            lines: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  chars:  { type: "array", items: { type: "string" } },
                  pinyin: { type: "array", items: { type: "string" } }
                },
                required: ["chars", "pinyin"],
                additionalProperties: false
              }
            }
          },
          required: ["section_type", "lines"],
          additionalProperties: false
        }
      }
    },
    required: ["unknown", "sections"],
    additionalProperties: false
  }.freeze

  def self.call(title:, raw_lyrics: nil)
    new(title: title, raw_lyrics: raw_lyrics).call
  end

  def initialize(title:, raw_lyrics: nil)
    @title = title
    @raw_lyrics = raw_lyrics
  end

  def call
    return mock_response if Rails.env.development? && ENV["ANTHROPIC_API_KEY"].blank?

    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY", nil))
    params = {
      model: MODEL,
      max_tokens: 4096,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: user_message }],
      output_config: { format: { type: "json_schema", schema: OUTPUT_SCHEMA } }
    }
    params[:tools] = [ WEB_SEARCH_TOOL ] if @raw_lyrics.blank?
    response = client.messages.create(**params)
    text_block = response.content.reverse.find { |b| b.type == "text" }
    JSON.parse(text_block.text)
  end

  def mock_response
    {
      "unknown" => false,
      "sections" => [
        {
          "section_type" => "Verse 1",
          "lines" => [
            { "chars" => ["你", "是", "我", "的", "神"], "pinyin" => ["nǐ", "shì", "wǒ", "de", "shén"] },
            { "chars" => ["我", "要", "赞", "美", "你"], "pinyin" => ["wǒ", "yào", "zàn", "měi", "nǐ"] }
          ]
        },
        {
          "section_type" => "Chorus",
          "lines" => [
            { "chars" => ["哈", "利", "路", "亚"], "pinyin" => ["hā", "lì", "lù", "yà"] },
            { "chars" => ["荣", "耀", "归", "于", "主"], "pinyin" => ["róng", "yào", "guī", "yú", "zhǔ"] }
          ]
        }
      ]
    }
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
