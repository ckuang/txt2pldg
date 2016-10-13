class TotalController < ApplicationController
  def show
    render json: {
      total: ::SmsPledge.sum(:amount)
    }
  end
end
