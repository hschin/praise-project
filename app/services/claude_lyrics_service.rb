class ClaudeLyricsService
  MODEL = "claude-sonnet-4-5-20250929"

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a Chinese worship music expert.
    When given a song title (and optionally raw lyrics), return the complete
    Simplified Chinese lyrics with tone-marked pinyin (e.g. nǐ hǎo, not ni3 hao3)
    structured into labeled sections.

    For each line, provide chars as an array of individual characters and pinyin
    as a parallel array of tone-marked syllables. One pinyin token per character.

    Example for line "你好":
      chars: ["你","好"], pinyin: ["nǐ","hǎo"]

    If you do not know the song with confidence, return sections: [] and unknown: true.
    Never fabricate lyrics you do not know.
  PROMPT

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
    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY", nil))
    response = client.messages.create(
      model: MODEL,
      max_tokens: 4096,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: user_message }],
      output_config: { format: { type: "json_schema", schema: OUTPUT_SCHEMA } }
    )
    JSON.parse(response.content[0].text)
  end

  private

  def user_message
    if @raw_lyrics.present?
      "Song title: #{@title}\n\nRaw lyrics to structure:\n#{@raw_lyrics}"
    else
      "Song title: #{@title}\n\nPlease recall and return the complete lyrics for this song."
    end
  end
end
