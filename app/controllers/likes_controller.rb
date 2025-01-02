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
        format.html { redirect_to posts_path, alert: "You already liked this post." }
      end
    end
  end

  def destroy
    @like = Like.find(params[:id])
    @post = @like.post

    if @like.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to posts_path, notice: "Like removed." }
      end
    else
      respond_to do |format|
        format.html { redirect_to posts_path, alert: "Could not remove like." }
      end
    end
  end
end
