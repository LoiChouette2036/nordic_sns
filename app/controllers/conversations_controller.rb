class ConversationsController < ApplicationController
  before_action :authenticate_user!
  def index
    @conversations = Conversation.where(
      "(sender_id = :user_id OR receiver_id = :user_id) AND status = :status",
      user_id: current_user.id,
      status: "accepted"
    )
  end

  def create
    receiver = User.find(params[:receiver_id])
    # we create the conv in pending
    conversation = Conversation.new(sender: current_user, receiver: receiver, status: "pending")

    if conversation.save
      # Broadcast Turbo Stream update
      broadcast_append_to(
        receiver,
        target: "pending-requests",
        partial: "pending_requests",
        locals: { current_user: receiver }
      )
      render json: { success: true, message: "Conversation request sent" }, status: :ok
    else
      render json: { success: false, errors: conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # 1) Find the conversation
    @conversations = Conversation.find(params[:id])

    # 2) Extract the new status (accepted or declined)
    new_status = params[:status]

    # 3) Check if the status is valid
    if new_status.in?(%w[accepted declined])
      # 4) Update the conversation in DB
      @conversation.update!(status: new_status)

      # 5) If accepted, update the conversation lists for both users
      if new_status == "accepted"
          broadcast_replace_to(
            @conversation.sender,
            target:  "conversations-list",
            partial: "conversations/conversations_list",
            locals:  {
              conversations: accepted_conversations_for(@conversation.sender)
            }
          )

          broadcast_replace_to(
            @conversation.receiver,
            target: "conversations-list",
            partial: "conversations/conversations_list",
            locals: {
              conversations: accepted_conversations_for(@conversation.receiver)
            }
          )
      end

      # 6) In any case (accepted or declined), remove from pending requests for the current_user
      broadcast_replace_to(
        current_user,
        target:  "pending-requests",
        partial: "pending_requests",
        locals:  { current_user: current_user }
      )

      # 7) Respond in Turbo Stream (if request is turbo) or redirect in HTML
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path(current_user.profile) }
      end
    else
      # If status is invalid => error
      render json: { success: false, error: "Invalid status" }, status: :unprocessable_entity
    end
  end

  def show
    # Optional: if you need a page to see the conversation details
    @conversation = Conversation.find(params[:id])
    # Implement your logic to show messages, etc.
  end

  private

  def accepted_conversations_for(user)
    Conversation.where("(sender_id = :user_id OR receiver_id = :user_id) AND status = 'accepted'", user_id: user.id)
  end
end
