module ApplicationHelper
  SECTION_TYPE_TRANSLATIONS = {
    "主歌" => "Verse", "verse" => "Verse",
    "副歌" => "Chorus", "chorus" => "Chorus",
    "桥段" => "Bridge", "bridge" => "Bridge",
    "前奏" => "Intro", "intro" => "Intro",
    "尾奏" => "Outro", "outro" => "Outro",
    "结尾" => "Outro",
    "诗歌" => "Song",
    "pre-chorus" => "Pre-Chorus", "前副歌" => "Pre-Chorus",
    "tag" => "Tag", "尾声" => "Tag"
  }.freeze

  def localized_section_type(section_type)
    SECTION_TYPE_TRANSLATIONS[section_type.to_s] ||
      SECTION_TYPE_TRANSLATIONS[section_type.to_s.downcase] ||
      section_type.to_s.humanize
  end
end
