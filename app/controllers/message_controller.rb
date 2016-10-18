class MessageController < ApplicationController
  def show
    render json: {
      pledges: SmsPledge.joins(:donor).where("name is not null")
    }
  end
end
