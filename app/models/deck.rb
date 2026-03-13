class Deck < ApplicationRecord
  belongs_to :user
  belongs_to :theme, optional: true
  has_many :deck_songs, -> { order(position: :asc) }, dependent: :destroy
  has_many :songs, through: :deck_songs

  validates :title, presence: true
  validates :date, presence: true
end
