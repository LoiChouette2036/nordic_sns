module ApplicationHelper
  def conversation_partner(conversation)
    current_user == conversation.sender ? conversation.receiver.profile.name : conversation.sender.profile.name
  end
end
