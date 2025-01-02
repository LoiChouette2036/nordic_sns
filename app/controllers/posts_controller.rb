class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @post = Post.new
    @posts = Post.where(parent_post_id: nil) # Top-level posts only
                 .includes(:replies, :user) # Preload replies and users
                 .order(created_at: :desc)
                 .page(params[:page]) # Add pagination
                 .per(20) # 50 posts per page

    respond_to do |format|
      format.html # standard full-page load
      format.turbo_stream # Handles turbo stream requests
    end
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      respond_to do |format|
        if @post.parent_post_id.present? # check if it s a comment
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.prepend(
                "comments_#{@post.parent_post_id}",
                partial: "posts/comment",
                locals: { comment: @post }
              ),
              turbo_stream.replace(
                "new_comment_form_#{@post.parent_post_id}",
                partial: "posts/comment_form",
                locals: { post: Post.new, parent_post_id: @post.parent_post_id }
              )
            ]
          end
        else
          format.turbo_stream # handles new posts
          format.html { redirect_to posts_path, notice: "Post created successfully" }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_post_form", partial: "posts/form", locals: { post: @post }) }
        format.html { redirect_to posts_path, alert: "Failed to create post." }
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:content, :parent_post_id)
  end
end
