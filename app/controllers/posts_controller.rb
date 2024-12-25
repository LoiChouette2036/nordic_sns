class PostsController < ApplicationController
  before_action :authenticate_user!, only: [ :create ]

  def index
    @post = Post.new
    @posts = Post.where(parent_post_id: nil) # Top-level posts only
                 .includes(:replies, :user) # Preload replies and users
                 .order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
    if @post
      puts "Replies: #{@post.replies.as_json}"
      render json: @post.as_json(include: { user: {}, replies: { include: :user } })
    else
      render json: { error: "Post not found" }, status: :not_found
    end
  end

  def create
    @post = current_user.posts.new(post_params)

    # Set parent_post_id if provided
    if params[:post][:parent_post_id].present?
      @post.parent_post_id = params[:post][:parent_post_id]
    end

    if @post.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "comments_list_#{@post.parent_post_id || @post.id}",
            partial: "posts/comment",
            locals: { comment: @post }
          )
        end
        format.html { redirect_to posts_path, notice: "Post created successfully" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_comment_form",
            partial: "posts/form",
            locals: { post: @post }
          )
        end
        format.html { redirect_to posts_path, alert: "Error creating post" }
      end
    end
  end


  private

  def post_params
    params.require(:post).permit(:content, :parent_post_id)
  end
end
