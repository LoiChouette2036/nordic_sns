class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :sender_id, uniqueness: { scope: :receiver_id }
  validates :status, inclusion: { in: %w[pending accepted declined] }

  validate :sender_and_receiver_must_be_different

  private

  def sender_and_receiver_must_be_different
    errors.add(:receiver_id, "cannot be the same as sender") if sender_id == receiver_id
  end
end
