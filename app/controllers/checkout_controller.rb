class CheckoutController < ApplicationController
  # This controller only shows a success or cancel page after Stripe checkout
  def success
    # Here, we simply display a "thank you" page
  end

  def cancel
    # Here, we display a "you canceled" page
  end
end
