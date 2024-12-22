class Profile < ApplicationRecord
  belongs_to :user

  # List of Norse deities
  NORSE_DEITIES = [
    "Odin", "Thor", "Freya", "Loki", "Balder", "Heimdall", "Tyr", "Njord", "Frigg", "Skadi", "Hel", "Eir", "Idun", "Bragi", "Sif"
  ]

  validates :name, presence: true
  validates :patron_deity, inclusion: { in: NORSE_DEITIES, message: "%{value} is not a valid deity" }
  validates :image, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
end
