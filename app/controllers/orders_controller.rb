class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.includes(:product)
  end

  def show
    @order = current_user.orders.includes(:product).find(params[:id])
  end
end
