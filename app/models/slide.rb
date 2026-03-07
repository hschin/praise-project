class Slide < ApplicationRecord
  belongs_to :deck_song
  belongs_to :lyric, optional: true

  validates :position, presence: true
end
