class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true

  after_create_commit do
    broadcast_append_to(
      "conversation_#{conversation.id}_messages",
      target: "messages",
      partial: "messages/message",
      locals: { message: self }
    )
  end
end
