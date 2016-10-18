class MessageController < ApplicationController
  def show
    render json: {
      pledges: SmsPledge.where("donor is not null")
    }
  end
end
