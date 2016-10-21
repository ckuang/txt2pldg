class ContactController < ApplicationController
  def show
    @pledges = SmsPledge.joins(:donor)
  end
end
