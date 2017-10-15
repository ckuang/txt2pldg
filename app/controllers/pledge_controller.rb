require 'twilio-ruby'

class PledgeController < ApplicationController
  include Webhookable
  after_filter :set_header
  skip_before_action :verify_authenticity_token

  INVALID_AMOUNT_ERROR_MESSAGE = "That doesn't seem like a valid pledge amount. Please enter a number (eg. $25)"
  INVALID_RESPONSE_ERROR_MESSAGE = "Sorry, that was an invalid response. Would you like to display a message?(Reply with Y or N)"

  def receive_message
    throw_invalid_amount = Proc.new {
      response = Twilio::TwiML::Response.new do |r|
        r.Message INVALID_AMOUNT_ERROR_MESSAGE
      end

      render_twiml response
    }
    throw_invalid_response = Proc.new {
      response = Twilio::TwiML::Response.new do |r|
        r.Message INVALID_RESPONSE_ERROR_MESSAGE
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
    elsif donor.steps % 5 == 1
      response = sequence(1)
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
          render_twiml response
    elsif donor.steps % 5 == 2
      response = sequence(2)
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
          render_twiml response
    elsif donor.steps % 5 == 3
      response = sequence(3)
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
          render_twiml response
    elsif donor.steps % 5 == 4
      response = sequence(4)
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
          render_twiml response
    elsif donor.steps % 5 == 0
      response = sequence(5)
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
      donor.update_attribute(:steps, 1)
      d.pledges << pledge
      response = Twilio::TwiML::Response.new do |r|
        r.Message "We appreciate your pledge! What's your first and last name?"
      end
    }

    p2 = Proc.new {
      donor.update_attribute(:name, params[:Body])
      donor.update_attribute(:steps, (donor.steps + 1))
      output = "Would you like to display a message?(Reply with Y or N)"
      response = Twilio::TwiML::Response.new do |r|
        r.Message output
      end
    }

    p3 = Proc.new {
      if (params[:Body] == "Y" || params[:Body] == "y")
        message_present = true
      elsif (params[:Body] == "N" || params[:Body] == "n")
        message_present = false
      end
      donor.pledges.first.update_attribute(:message_present, message_present)
      if donor.pledges.first.message_present
        donor.update_attribute(:steps, (donor.steps + 1))
        response = Twilio::TwiML::Response.new do |r|
          r.Message "Enter your message."
        end
      else
        donor.update_attribute(:steps, (donor.steps + 2))
        response = Twilio::TwiML::Response.new do |r|
          r.Message "What's your email?"
        end
      end
    }

    p4 = Proc.new {
      donor.pledges.first.update_attribute(:message, params[:Body])
      donor.update_attribute(:steps, (donor.steps + 1))
      response = Twilio::TwiML::Response.new do |r|
        r.Message "What's your email?"
      end
    }

    p5 = Proc.new {
      donor.update_attribute(:email, params[:Body])
      donor.update_attribute(:steps, (donor.steps + 1))
      response = Twilio::TwiML::Response.new do |r|
        r.Message "How would you like to fulfill your pledge? Reply 1 for Venmo instructions. Reply 2 to donate through C4Q's webpage."
      end
    }

    p6 = Proc.new {
      donor.pledges.first.update_attribute(:payment, params[:Body])
      donor.update_attribute(:steps, 1)
      if (donor.pledges.first.payment == 1 || donor.pledges.first.payment == "1")
        response = Twilio::TwiML::Response.new do |r|
          r.Message "Please venmo @c4qnyc your pledge amount. Thanks for your contribution and enjoy the rest of your evening!"
        end
      else
        response = Twilio::TwiML::Response.new do |r|
          r.Message "Please visit http://c4q.nyc/donate. Thanks for your contribution and enjoy the rest of your evening!"
        end
      end
    }


    [p1, p2, p3, p4, p5, p6][idx].call
  end

  def donor
    @donor if defined?(@donor)
    SmsDonor.where(phone_number: params[:From]).last
  end

end
