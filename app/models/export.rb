class Export < ApplicationRecord
  belongs_to :deck
  belongs_to :user

  enum :event, { generated: "generated", downloaded: "downloaded" }
end
