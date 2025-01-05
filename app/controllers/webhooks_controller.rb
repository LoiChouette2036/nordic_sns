class WebhooksController < ApplicationController
  # Disable CSRF verification for this controller because Stripe webhooks won't send a CSRF token
  skip_before_action :verify_authenticity_token

  # This method is called whenever Stripe sends a webhook event to '/webhooks/stripe'
  def stripe
    # Read the raw request body sent by Stripe
    payload = request.body.read

    # Stripe includes a signature in the headers to verify the webhook request
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    event = nil # Variable to store the parsed webhook event

    # Verify the webhook and construct the event object
    begin
      event = Stripe::Webhook.construct_event(
        payload,              # Raw body of the webhook
        sig_header,           # Stripe's signature header to verify authenticity
        ENV["STRIPE_ENDPOINT_SECRET"] # Your secret key for verifying the webhook
      )
    rescue JSON::ParserError
      # If the payload can't be parsed as JSON, return a 400 Bad Request response
      render json: { error: "Invalid payload" }, status: 400
      return
    rescue Stripe::SignatureVerificationError
      # If the signature verification fails, return a 400 Bad Request response
      render json: { error: "Invalid signature" }, status: 400
      return
    end

    # Handle different types of events sent by Stripe
    case event["type"]
    when "checkout.session.completed"
      # This event is triggered when a checkout session is successfully completed
      session = event["data"]["object"] # Extract the session data from the event
      handle_checkout_session(session)  # Call the method to handle this event
    end

    # Respond to Stripe to acknowledge receipt of the webhook
    render json: { message: "Webhook received" }
  end

  private

  # This method processes the checkout session when payment is completed
  def handle_checkout_session(session)
    # find the product and user based on the session metadata
    product = Product.find_by(id: session.metadata.product_id)
    user = User.find_by(id: session.metadata.user_id)

    # Create an order only if both are valid
    if product && user
      Order.create!(
        user: user,
        product: product,
        total_price: session.amount_total / 100.0, # Stripe gives amount in cents
        status: "paid"
      )
    else
      Rails.logger.error "Invalid product or user for session: #{session.id}"
    end
  end
end
