module ApplicationHelper
  SECTION_TYPE_KEY_MAP = {
    "主歌" => :verse,   "verse" => :verse,
    "副歌" => :chorus,  "chorus" => :chorus,
    "桥段" => :bridge,  "bridge" => :bridge,
    "前奏" => :intro,   "intro" => :intro,
    "尾奏" => :outro,   "outro" => :outro,   "结尾" => :outro,
    "诗歌" => :song,
    "pre-chorus" => :pre_chorus, "前副歌" => :pre_chorus,
    "tag" => :tag,      "尾声" => :tag
  }.freeze

  def localized_section_type(section_type)
    key = SECTION_TYPE_KEY_MAP[section_type.to_s] ||
          SECTION_TYPE_KEY_MAP[section_type.to_s.downcase]
    key ? t("section_types.#{key}") : section_type.to_s.humanize
  end
end
