class Lyric < ApplicationRecord
  belongs_to :song

  validates :section_type, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :content, presence: true
end
