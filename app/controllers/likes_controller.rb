class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @like = current_user.likes.new(like_params)
    @post = @like.post
    if @like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: "Post liked!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("like_errors", partial: "shared/errors", locals: { errors: @like.errors.full_messages }) }
        format.html { redirect_to @post, alert: @like.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @like = current_user.likes.find_by(id: params[:id])
    @post = @like&.post
    if @like
      @like.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: "Like removed." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("like_errors", partial: "shared/errors", locals: { errors: [ "Like not found or already removed." ] }) }
        format.html { redirect_to posts_path, alert: "Like not found or already removed." }
      end
    end
  end

  private

  def like_params
    params.require(:like).permit(:post_id)
  end
end
