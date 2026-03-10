class Song < ApplicationRecord
  has_many :lyrics, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :lyrics
  has_many :deck_songs, dependent: :destroy
  has_many :decks, through: :deck_songs

  validates :title, presence: true

  enum :import_status, {
    pending:    "pending",
    processing: "processing",
    done:       "done",
    failed:     "failed"
  }
end
