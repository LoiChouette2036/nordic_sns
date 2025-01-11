# app/controllers/webhook_controller.rb

class WebhooksController < ApplicationController
  # We skip CSRF checks for webhooks
  skip_before_action :verify_authenticity_token

  def stripe
    # This method handles incoming Stripe webhook events
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = "TON_WEBHOOK_SIGNING_SECRET"
    # You get it from the Stripe Dashboard (Webhook settings)

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Signature verification failed" }, status: 400
      return
    end

    # We handle the event type
    case event.type
    when "checkout.session.completed"
      session_object = event.data.object

      # Retrieve shipping details
      shipping = session_object.shipping_details
      # shipping.name, shipping.phone, shipping.address (line1, line2, city, postal_code, country)

      # Retrieve metadata
      product_id = session_object.metadata.product_id
      user_id    = session_object.metadata.user_id

      Rails.logger.info ">>> Checkout completed!"
      Rails.logger.info ">>> Shipping name: #{shipping.name}"
      Rails.logger.info ">>> Address line1: #{shipping.address.line1}"
      Rails.logger.info ">>> Product ID: #{product_id}, Buyer ID: #{user_id}"
      Rails.logger.info ">>> If you want to store them, do it here."

      # If you want, you could create a local record or do something else
      # e.g. create an 'Order' in your DB, but that's optional

    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    render json: { success: true }, status: 200
  end
end
