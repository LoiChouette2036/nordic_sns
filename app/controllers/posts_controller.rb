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
    # @post = Post.new(post_params)
    # @post.user - current_user
    # these lines are equal to the one below :)
    @post = current_user.posts.new(post_params) # automaticcaly sets user_id

    if params[:parent_post_id].present?
      @post.parent_post_id = params[:parent_post_id]
    end

    if @post.save
      redirect_to posts_path, notice: "Post created successfully"
    else
      @posts = Post.where(parent_post_id: nil).includes(:replies, :user).order(created_at: :desc)
      render :index
    end
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
