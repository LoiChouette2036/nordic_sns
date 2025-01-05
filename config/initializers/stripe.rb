Stripe.api_key = ENV["STRIPE_SECRET_KEY"] # Secret key for backend API calls

Rails.configuration.stripe = {
  public_key: ENV["STRIPE_PUBLIC_KEY"], # Public key for frontend usage
  secret_key: ENV["STRIPE_SECRET_KEY"]  # Secret key (for reference if needed)
}
