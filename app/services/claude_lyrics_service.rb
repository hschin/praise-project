class ClaudeLyricsService
  MODEL = "claude-sonnet-4-5-20250929"

  SEARCH_SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a Chinese worship music expert helping disambiguate song searches.
    
    When given a song title (and optionally artist name), use web search to find 
    matching Chinese worship songs. Be thorough and search multiple times if needed.
    
    Search strategy:
    1. First search: "[title] [artist] 歌词" or "[title] 歌词 赞美诗"
    2. If no results, try: "[title] lyrics chinese worship"
    3. If still no results, try variations of the title (simplified/traditional Chinese)
    
    Common Chinese worship artists to recognize:
    - 赞美之泉 (Stream of Praise / 讚美之泉)
    - 约书亚乐团 (Joshua Band)
    - 生命河灵粮堂 (River of Life)
    - 盛晓玫 (Amy Sand)
    - 泥土音乐 (Clay Music)
    - 新心音乐 (New Heart Music Ministries)
    
    For each candidate you find, provide:
    - title: the full song title in Simplified Chinese (convert from Traditional if needed)
    - artist: the artist/worship leader/band name (Simplified Chinese preferred, English in parentheses if known)
    - album: album name if available
    - year: release year if available (just the number)
    - snippet: a 1-2 line excerpt from the Chinese lyrics (NOT just the title repeated)
    
    Return up to 5 candidates, ordered by relevance (most likely match first).
    If you find only one clear match, return it as a single-item array.
    If you genuinely cannot find ANY matching Chinese worship song after thorough searching, return an empty array.
    
    Return format:
    {
      "candidates": [
        { "title": "...", "artist": "...", "album": "...", "year": "...", "snippet": "..." }
      ]
    }
    
    Respond with raw JSON only — no markdown code fences, no explanation text.
  PROMPT

  LYRICS_SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a Chinese worship music expert.
    When given a song title and artist, return the complete lyrics in Simplified
    Chinese with tone-marked pinyin (e.g. nǐ hǎo, not ni3 hao3) structured into
    labeled sections.
    Always convert Traditional Chinese characters to Simplified Chinese in your output,
    even if the input or source lyrics are in Traditional Chinese.

    For each line, provide chars as an array of individual characters and pinyin
    as a parallel array of tone-marked syllables. One pinyin token per character.

    Example for line "你好":
      chars: ["你","好"], pinyin: ["nǐ","hǎo"]

    Always label section_type in English (e.g. "Verse 1", "Verse 2", "Chorus", "Bridge", "Pre-Chorus", "Intro", "Outro", "Tag").

    Use web search to find the complete, accurate lyrics for this specific song.
    If you cannot find the song after searching, return sections: [] and unknown: true.
    Never fabricate lyrics you do not know.

    Respond with raw JSON only — no markdown code fences, no explanation text.
  PROMPT

  PASTE_LYRICS_SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a Chinese worship music expert.
    The user has pasted raw lyrics. Your ONLY job is to:
    1. Structure those exact lyrics into labeled sections
    2. Add tone-marked pinyin (e.g. nǐ hǎo, not ni3 hao3) for each character
    3. Convert any Traditional Chinese characters to Simplified Chinese

    CRITICAL: Use ONLY the lyrics provided. Do NOT search the web. Do NOT substitute
    or supplement with lyrics from your training data. If the pasted text is incomplete,
    structure only what was given.

    For each line, provide chars as an array of individual characters and pinyin
    as a parallel array of tone-marked syllables. One pinyin token per character.

    Example for line "你好":
      chars: ["你","好"], pinyin: ["nǐ","hǎo"]

    Always label section_type in English (e.g. "Verse 1", "Verse 2", "Chorus", "Bridge", "Pre-Chorus", "Intro", "Outro", "Tag").

    Respond with raw JSON only — no markdown code fences, no explanation text.
  PROMPT

  WEB_SEARCH_TOOL = { type: "web_search_20250305", name: "web_search" }.freeze

  # Search for song candidates (disambiguation step)
  def self.search(title:, artist: nil)
    new(title: title, artist: artist, mode: :search).call
  end

  # Import full lyrics for a specific song (after selection)
  def self.import(title:, artist:, raw_lyrics: nil)
    new(title: title, artist: artist, raw_lyrics: raw_lyrics, mode: :import).call
  end

  def initialize(title:, artist: nil, raw_lyrics: nil, mode: :import)
    @title = title
    @artist = artist
    @raw_lyrics = raw_lyrics
    @mode = mode
  end

  def call
    case @mode
    when :search
      search_candidates
    when :import
      import_lyrics
    end
  end

  private

  def search_candidates
    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY", nil))
    params = {
      model: MODEL,
      max_tokens: 2048,
      temperature: 0.3, # Lower temperature for more consistent results
      system: SEARCH_SYSTEM_PROMPT,
      tools: [ WEB_SEARCH_TOOL ],
      messages: [
        { role: "user", content: search_user_message },
        { role: "assistant", content: "{" }
      ]
    }
    response = client.messages.create(**params)
    text_block = response.content.reverse.find { |b| b.type == :text }
    result = parse_json(text_block&.text, context: "search")

    # Fallback: if no candidates found, try a second search with different query
    if result["candidates"].nil? || result["candidates"].empty?
      Rails.logger.warn("[ClaudeLyricsService] First search returned no results, trying fallback search")
      params[:messages] = [
        { role: "user", content: fallback_search_message },
        { role: "assistant", content: "{" }
      ]
      response = client.messages.create(**params)
      text_block = response.content.reverse.find { |b| b.type == :text }
      result = parse_json(text_block&.text, context: "search_fallback")
    end

    result
  end

  def import_lyrics
    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY", nil))
    system_prompt = @raw_lyrics.present? ? PASTE_LYRICS_SYSTEM_PROMPT : LYRICS_SYSTEM_PROMPT
    params = {
      model: MODEL,
      max_tokens: 4096,
      temperature: 0.2,
      system: system_prompt,
      messages: [
        { role: "user", content: import_user_message },
        { role: "assistant", content: "{" }
      ]
    }
    params[:tools] = [ WEB_SEARCH_TOOL ] if @raw_lyrics.blank?
    response = client.messages.create(**params)
    text_block = response.content.reverse.find { |b| b.type == :text }
    result = parse_json(text_block&.text, context: "import")
    validate_sections!(result)
    result
  end

  def search_user_message
    msg = "Song title: #{@title}"
    msg += "\nArtist: #{@artist}" if @artist.present?
    msg += "\n\nPlease search the web thoroughly for this Chinese worship song. "
    msg += "Try multiple search queries if needed:\n"
    msg += "1. \"#{@title}#{@artist.present? ? " #{@artist}" : ""} 歌词\"\n"
    msg += "2. \"#{@title} lyrics chinese worship\"\n"
    msg += "3. \"#{@title} 赞美诗 歌词\"\n\n"
    msg += "Return up to 5 matching candidates with complete metadata."
    msg
  end

  def fallback_search_message
    # Try English search if Chinese didn't work
    msg = "Song title: #{@title}"
    msg += "\nArtist: #{@artist}" if @artist.present?
    msg += "\n\nPrevious search returned no results. "
    msg += "Try broader search queries:\n"
    msg += "1. \"#{@title} chinese christian song\"\n"
    msg += "2. \"#{@title} worship song lyrics\"\n"
    msg += "3. Search for the artist name if provided: \"#{@artist} songs\" (find their catalog)\n\n"
    msg += "Return any matching Chinese worship songs you find."
    msg
  end

  def import_user_message
    if @raw_lyrics.present?
      "Song title: #{@title}\nArtist: #{@artist}\n\nRaw lyrics to structure:\n#{@raw_lyrics}"
    else
      "Song title: #{@title}\nArtist: #{@artist}\n\nSearch the web for the complete lyrics for this specific song, then return them structured with pinyin."
    end
  end

  def parse_json(text, context:)
    raise ArgumentError, "Empty response from Claude (#{context})" if text.blank?

    JSON.parse("{" + text)
  rescue JSON::ParserError => e
    Rails.logger.error("[ClaudeLyricsService] JSON parse failure (#{context}): #{e.message} | raw=#{text.truncate(200)}")
    { "candidates" => [], "sections" => [], "unknown" => true }
  end

  def validate_sections!(result)
    sections = result["sections"]
    return unless sections.is_a?(Array)

    sections.each_with_index do |section, i|
      lines = section["lines"]
      raise ArgumentError, "Section #{i} missing 'lines' array" unless lines.is_a?(Array)

      lines.each_with_index do |line, j|
        unless line["chars"].is_a?(Array) && line["pinyin"].is_a?(Array)
          raise ArgumentError, "Section #{i} line #{j} missing 'chars'/'pinyin' arrays"
        end
      end
    end
  end
end
