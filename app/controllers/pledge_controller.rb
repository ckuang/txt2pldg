require 'twilio-ruby'

class PledgeController < ApplicationController
  include Webhookable
  after_filter :set_header
  skip_before_action :verify_authenticity_token

  INVALID_AMOUNT_ERROR_MESSAGE = "That doesn't seem like a valid pledge amount. Please enter a number (eg. $25)"

  def receive_message
    throw_invalid_amount = Proc.new {
      response = Twilio::TwiML::Response.new do |r|
        r.Message INVALID_AMOUNT_ERROR_MESSAGE
      end

      render_twiml response
    }
    if donor.nil?
      begin
        response = sequence(0)
        donor.messages << SmsDonorMessage.create_message_from_twilio(params)
        render_twiml response
      rescue
        throw_invalid_amount.call
      end
    elsif donor.messages.count % 4 == 1
      response = sequence(1)
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
          render_twiml response
    elsif donor.messages.count % 4 == 2
      response = sequence(2)
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
          render_twiml response
    elsif donor.messages.count % 4 == 3
      response = sequence(3)
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
          render_twiml response
    elsif !donor.nil? and donor.messages.count % 4 == 0
      begin
        response = sequence(0)
        donor.messages << SmsDonorMessage.create_message_from_twilio(params)
            render_twiml response
      rescue
        throw_invalid_amount.call
      end
    end

  end

  private

  def sequence(idx)
    p1 = Proc.new {
      amount = params[:Body].gsub("$", "").gsub(",", "").gsub("-", "")
      raise "Invalid amount type" if amount.to_i == 0
      d = SmsDonor.create_from_twilio_response(params)
      pledge = SmsPledge.create(amount: amount.to_f)
      d.pledges << pledge
      response = Twilio::TwiML::Response.new do |r|
        r.Message "We appreciate your contribution! What's your name so we know who to thank?"
      end
    }

    p2 = Proc.new {
      donor.update_attribute(:name, params[:Body])
      output = "Thanks " + donor.name + "! Why do you want to support C4Q?(your message will be displayed on the public pledge board)"
      response = Twilio::TwiML::Response.new do |r|
        r.Message output
      end
    }

    p3 = Proc.new {
      donor.pledges.first.update_attribute(:message, params[:Body])
      response = Twilio::TwiML::Response.new do |r|
        r.Message "What's your email? We want to stay connected!"
      end
    }

    p4 = Proc.new {
      donor.update_attribute(:email, params[:Body])
      response = Twilio::TwiML::Response.new do |r|
        r.Message "Great! Thanks again for your donation. Enjoy the evening!"
      end
    }

    [p1, p2, p3, p4][idx].call
  end

  def donor
    @donor if defined?(@donor)
    SmsDonor.where(phone_number: params[:From]).last
  end

end
