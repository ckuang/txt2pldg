class MessageController < ApplicationController
  def show
    render json: {
      pledges: SmsPledge.all
    }
  end
end
