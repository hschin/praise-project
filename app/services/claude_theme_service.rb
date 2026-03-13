class ClaudeThemeService
  MODEL = "claude-3-5-haiku-20241022"

  def self.call(deck:)
    new(deck: deck).call
  end

  def initialize(deck:)
    @deck   = deck
    @client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY", nil))
  end

  def call
    prompt = build_prompt
    response = @client.messages.create(
      model: MODEL,
      max_tokens: 1024,
      messages: [{ role: "user", content: prompt }]
    )
    raw_json = response.content.first.text
    JSON.parse(raw_json.match(/\[.*\]/m)&.to_s || "[]")
  rescue => e
    Rails.logger.error("[ClaudeThemeService] #{e.class}: #{e.message}")
    []
  end

  private

  def build_prompt
    <<~PROMPT
      You are helping a church worship team choose a visual theme for their service deck titled "#{@deck.title}".

      Return a JSON array of exactly 5 theme suggestions. Each suggestion must have these keys:
      - "name": a short evocative theme name (2-4 words)
      - "background_color": a dark hex color suitable for projection (e.g. "#1a3a5c")
      - "text_color": a light hex color for text on that background (e.g. "#ffffff")
      - "font_size": one of "small", "medium", or "large"
      - "unsplash_query": 2-4 English keywords for an Unsplash landscape photo (e.g. "sunrise mountain worship")

      Return ONLY the JSON array, no explanation, no markdown code block.
    PROMPT
  end
end
