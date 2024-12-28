class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [ :show, :edit, :update ]
  def new
    @profile = Profile.new
  end

  def create
    @profile = current_user.build_profile(profile_params)
    if @profile.save
      redirect_to profile_path, notice: "Profile created successfully"
    else
      render :new, alert: "Error creating profile."
    end
  end

  def show
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully"
    else
      render :edit, alert: "Error updating profile"
    end
  end

  def test_turbo_stream
    render turbo_stream: turbo_stream.append(
      "pending-requests",
      partial: "conversations/pending_request",
      locals: { conversation: Conversation.last }
    )
  end

  def test_broadcast
    render turbo_stream: turbo_stream.append("pending-requests", "<p>Test broadcast</p>")
  end


  private

  def set_profile
    @profile = current_user.profile
  end

  def profile_params
    params.require(:profile).permit(:name, :bio, :image, :patron_deity)
  end
end
