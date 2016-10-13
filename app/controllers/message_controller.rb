class MessageController < ApplicationController
  def show
    render json: {
      pledges: SmsPledge.where("message is not null")
    }
  end
end
