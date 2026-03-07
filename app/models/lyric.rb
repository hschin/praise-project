class Lyric < ApplicationRecord
  belongs_to :song

  validates :section_type, presence: true
  validates :position, presence: true
  validates :content, presence: true
end
