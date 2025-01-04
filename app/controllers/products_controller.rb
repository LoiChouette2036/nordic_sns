class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
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
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to product_path(@product), notice: "Product updated successfully!"
    else
      flash.now[:alert] = "Failed to update product. Please check the form for errors."
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      redirect_to products_path, notice: "Product was successfully deleted."
    else
      redirect_to product_path(@product), alert: "Failed to delete product."
    end
  end

  private

  def product_params
    params.require(:product).permit(:title, :description, :price, :quantity, :image)
  end
end
