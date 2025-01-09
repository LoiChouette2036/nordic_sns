class Profile < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  # List of Norse deities
  NORSE_DEITIES = [
    "Odin", "Thor", "Freya", "Loki", "Balder", "Heimdall", "Tyr", "Njord", "Frigg", "Skadi", "Hel", "Eir", "Idun", "Bragi", "Sif"
  ]

  validates :name, presence: true
  validates :patron_deity, inclusion: { in: NORSE_DEITIES, message: "%{value} is not a valid deity" }
end
