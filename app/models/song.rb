class Song < ApplicationRecord
  has_many :lyrics, -> { order(position: :asc) }, dependent: :destroy
  has_many :deck_songs, dependent: :destroy
  has_many :decks, through: :deck_songs

  validates :title, presence: true
end
