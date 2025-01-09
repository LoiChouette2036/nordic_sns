class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_product_owner, only: [ :edit, :update, :destroy ]
  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user # Ensure user_id is correctly set

    if @product.save
      redirect_to product_path(@product), notice: "Product created successfully!"
    else
      flash.now[:alert] = "Failed to create product. Please check the form for errors."
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to product_path(@product), notice: "Product updated successfully!"
    else
      flash.now[:alert] = "Failed to update product. Please check the form for errors."
      render :edit
    end
  end

  def destroy
    if @product.destroy
      redirect_to products_path, notice: "Product was successfully deleted."
    else
      redirect_to product_path(@product), alert: "Failed to delete product."
    end
  end

  def create_checkout_session
    product = Product.find(params[:id])

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "usd",
          product_data: {
            name: product.title
          },
          unit_amount: (product.price * 100).to_i # Stripe expects the amount in cents
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: checkout_success_url, # Redirect after a successful payment
      cancel_url: checkout_cancel_url,    # Redirect if the user cancels the payment
      metadata: {
        product_id: product.id, # Add the product ID
        user_id: current_user.id # Add the user ID
      }
    )

    redirect_to session.url, allow_other_host: true
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def authorize_product_owner
    unless @product.user == current_user
      redirect_to products_path, alert: "You are not authorized to modify this product."
    end
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :quantity, :image)
  end
end
