class DeckSong < ApplicationRecord
  belongs_to :deck
  belongs_to :song
  has_many :slides, -> { order(position: :asc) }, dependent: :destroy

  validates :position, presence: true
end
