class UsersController < ApplicationController
  def search
    query = params[:query].to_s.strip.downcase # Get and clean the search query
    @users = User.joins(:profile).where("LOWER(profiles.name) LIKE ?", "#{query}%") # Search for matching names (case-insensitive)

    # Respond with only the necessary fields in JSON
    render json: @users.map { |user| { id: user.id, name: user.profile.name } }
  end
end
