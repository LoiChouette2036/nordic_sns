class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    Rails.logger.debug "Current user: #{current_user.inspect}"
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user = current_user
    @current_user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation), notice: "Message sent!" }
      end
    else
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), alert: "Failed to send message." }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
