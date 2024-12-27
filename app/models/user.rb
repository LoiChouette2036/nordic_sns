class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy

   # The user is the "sender" in these conversations
   has_many :sent_conversations,
   class_name:  "Conversation",
   foreign_key: :sender_id,
   dependent:   :destroy

  # The user is the "receiver" in these conversations
  has_many :received_conversations,
    class_name:  "Conversation",
    foreign_key: :receiver_id,
    dependent:   :destroy
end
