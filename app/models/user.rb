class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :sent_conversations, class_name: "Conversation", foreign_key: "sender_id", dependent: :destroy
  has_many :received_conversations, class_name: "Conversation", foreign_key: "receiver_id", dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy

  def conversations
    Conversation.where("sender_id = ? OR receiver_id = ?", id, id)
  end
end
