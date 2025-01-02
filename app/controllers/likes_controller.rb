# app/controllers/likes_controller.rb

class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    @like = @post.likes.build(user: current_user)

    if @like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to posts_path, notice: "Post liked!" }
      end
    else
      respond_to do |format|
        format.html { redirect_to posts_path, alert: "You have already liked this post." }
      end
    end
  end

  def destroy
    @like = Like.find_by(id: params[:id])
    @post = @like&.post || Post.find_by(id: params[:post_id])

    if @like
      @like.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to posts_path, notice: "Like removed." }
      end
    else
      if @post
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace("like_button_#{@post.id}") do
              render "likes/like_button", post: @post
            end
          }
          format.html { redirect_to posts_path, alert: "Like not found or already removed." }
        end
      else
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace("like_button_unknown") do
              content_tag(:div, "Unable to find the post associated with this like.", class: "alert alert-danger")
            end
          }
          format.html { redirect_to posts_path, alert: "Unable to find the post associated with this like." }
        end
      end
    end
  end
end
