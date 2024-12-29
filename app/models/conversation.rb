class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validate :sender_and_receiver_must_be_different
  validate :conversation_uniqueness, on: :create

  has_many :messages, dependent: :destroy

  # This broadcasts a new "pending" request to the receiver
  def broadcast_to_receiver
    broadcast_append_to(
      receiver,
      target: "pending-requests",
      partial: "conversations/pending_request",
      locals: { conversation: self }
    )
  end

  # Once accepted/declined, broadcast the conversation so it appears in /conversations index
  def broadcast_status_change
    [ sender, receiver ].each do |user|
      # Instead of broadcasting to "conversation_#{id}", we broadcast to "conversations"
      # so it appends a new conversation block into <div id="conversations"> in index.html.erb
      broadcast_append_to(
        user,
        target: "conversations",  # The <div id="conversations"> in index
        partial: "conversations/conversation",
        locals: { conversation: self }
      )
    end
  end

  private

  def sender_and_receiver_must_be_different
    if sender_id == receiver_id
      errors.add(:receiver_id, "cannot be the same as sender")
    end
  end

  def conversation_uniqueness
    if Conversation.exists?(sender: sender, receiver: receiver) ||
       Conversation.exists?(sender: receiver, receiver: sender)
      errors.add(:base, "Conversation between these users already exists")
    end
  end
end
