# BEGIN app/controllers/conversations_controller.rb

class ConversationsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :exception

  # List all accepted conversations for the current user
  def index
    @conversations = Conversation.where(
      "(sender_id = :user_id OR receiver_id = :user_id) AND status = :status",
      user_id: current_user.id,
      status: "accepted"
    )
  end

  # Create a new conversation request (status: "pending")
  def create
    Rails.logger.debug("Params received: #{params.inspect}")
    receiver = User.find_by(id: params[:receiver_id])

    if receiver.nil?
      render json: { success: false, errors: [ "Receiver not found" ] }, status: :unprocessable_entity
      return
    end

    if current_user == receiver
      render json: { success: false, errors: [ "You cannot start a conversation with yourself" ] }, status: :unprocessable_entity
      return
    end

    existing_conversation = Conversation.find_by(sender: current_user, receiver: receiver) ||
                            Conversation.find_by(sender: receiver, receiver: current_user)

    if existing_conversation
      render json: { success: false, message: "Conversation already exists" }, status: :unprocessable_entity
      return
    end

    # Create a new pending conversation
    conversation = Conversation.new(
      conversation_params.merge(sender: current_user, status: "pending")
    )

    if conversation.save
      # Broadcast the pending request to the receiver
      conversation.broadcast_to_receiver
      render json: { success: true, message: "Conversation request sent" }, status: :ok
    else
      render json: { success: false, errors: conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Update the conversation status (accept or decline)
  def update
    conversation = Conversation.find_by(id: params[:id])

    if conversation.nil?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash-messages",
            partial: "shared/flash",
            locals: { message: "Conversation not found", alert_type: :danger }
          )
        end
        format.html { redirect_to conversations_path, alert: "Conversation not found" }
      end
      return
    end

    if conversation.update(status: params[:status])
      # -------------------------------------------------------
      # ## CHANGE: We remove the pending request block from the user's profile
      # in BOTH cases (accepted or declined).
      # If declined, also destroy the conversation from DB.
      # If accepted, we broadcast so it appears in /conversations index.
      # -------------------------------------------------------

      if conversation.status == "declined"
        conversation.destroy
        respond_to do |format|
          format.turbo_stream do
            # Remove the "pending-request-XX" block from the profile
            render turbo_stream: turbo_stream.remove(
              "pending-request-#{conversation.id}"  # ## CHANGE: Remove pending partial
            )
          end
          format.html do
            redirect_to conversations_path, notice: "Conversation declined and removed."
          end
        end

      else
        # If accepted, broadcast the status change
        conversation.broadcast_status_change

        respond_to do |format|
          format.turbo_stream do
            # Remove the "pending-request-XX" block from the profile
            render turbo_stream: turbo_stream.remove(
              "pending-request-#{conversation.id}"  # ## CHANGE: Remove pending partial
            )
          end
          format.html do
            redirect_to conversations_path, notice: "Conversation status updated."
          end
        end
      end

    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash-messages",
            partial: "shared/flash",
            locals: {
              message: conversation.errors.full_messages.join(", "),
              alert_type: :danger
            }
          )
        end
        format.html { redirect_to conversations_path, alert: "Failed to update conversation" }
      end
    end
  end

  def show
    @conversation = Conversation.find(params[:id])
  end

  private

  def conversation_params
    params.require(:conversation).permit(:receiver_id)
  end
end

# END app/controllers/conversations_controller.rb
