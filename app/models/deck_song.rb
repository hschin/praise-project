class DeckSong < ApplicationRecord
  belongs_to :deck
  belongs_to :song
  has_many :slides, -> { order(position: :asc) }, dependent: :destroy

  validates :position, presence: true

  # arrangement stores an ordered array of lyric IDs representing the
  # performance sequence for this song in this deck. Lyric IDs can repeat
  # to indicate repeated sections (e.g. chorus sung twice).
  # Example: [1, 3, 1, 3, 3, 2, 3] where 3 is the chorus lyric ID.

  before_save :cast_arrangement_ids

  def safe_lyrics
    return [] if arrangement.blank?
    arrangement.filter_map { |id| Lyric.find_by(id: id) }
  end

  private

  def cast_arrangement_ids
    self.arrangement = arrangement&.map(&:to_i)
  end
end
