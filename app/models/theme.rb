class Theme < ApplicationRecord
  belongs_to :deck, optional: true
  has_one_attached :background_image

  validates :name, presence: true
  validates :source, inclusion: { in: %w[ai custom] }

  FONT_SIZE_PRESETS = { "small" => 28, "medium" => 36, "large" => 48 }.freeze
end
