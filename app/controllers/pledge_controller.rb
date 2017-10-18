require 'twilio-ruby'

class PledgeController < ApplicationController
  include Webhookable
  after_filter :set_header
  skip_before_action :verify_authenticity_token

  INVALID_AMOUNT_ERROR_MESSAGE = "Sorry, that doesn't seem like a valid pledge amount. Please enter a number (eg. $25)"
  INVALID_CHOICE_MESSAGE = "Sorry, that doesn't seem like a valid choice. Please reply 1 for Venmo instructions or reply 2 for C4Q's donation page."
  def receive_message
    throw_invalid_amount = Proc.new {
      response = Twilio::TwiML::Response.new do |r|
        r.Message INVALID_AMOUNT_ERROR_MESSAGE
      end

      render_twiml response
    }
    throw_invalid_choice = Proc.new {
      response = Twilio::TwiML::Response.new do |r|
        r.Message INVALID_CHOICE_MESSAGE
      end

      render_twiml response
    }

    send_message = Proc.new {
      donor.messages << SmsDonorMessage.create_message_from_twilio(params)
      render_twiml response
    }

    if donor.nil?
      begin
        response = sequence(0)
        send_message.call
      rescue
        throw_invalid_amount.call
      end
    elsif donor.steps >= 5 && (donor.steps - 5) % 2 == 0 && SmsPledge.sum(:amount)where(sms_donor_id: donor.id)
      response = sequence(6)
      send_message.call
    elsif donor.steps >= 5 && (donor.steps - 5) % 2 == 0
      response = sequence(7)
      send_message.call
    elsif donor.steps >= 5 && (donor.steps - 5) % 2 == 1
      response = sequence(4)
      send_message.call
    elsif donor.steps == 1
      response = sequence(1)
      send_message.call
    elsif donor.steps == 2
      response = sequence(2)
      send_message.call
    elsif donor.steps == 3 && donor.pledges.first.amount > 2999
      response = sequence(5)
      send_message.call
    elsif donor.steps == 3
      response = sequence(3)
      send_message.call
    elsif donor.steps == 4
      begin
        response = sequence(4)
        send_message.call
      rescue
        throw_invalid_choice.call
      end
    elsif

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
      output = "Who has inspired you tonight? Display a message for an honoree or alumni!"
      response = Twilio::TwiML::Response.new do |r|
        r.Message output
      end
    }

    p3 =  Proc.new {
      donor.pledges.first.update_attribute(:message, params[:Body])
      donor.update_attribute(:steps, (donor.steps + 1))
      response = Twilio::TwiML::Response.new do |r|
        r.Message "What's your email?"
      end
    }

    p4 = Proc.new {
      donor.update_attribute(:email, params[:Body])
      donor.update_attribute(:steps, (donor.steps + 1))
      response = Twilio::TwiML::Response.new do |r|
        r.Message "How would you like to fulfill your pledge? Reply 1 for Venmo instructions. Reply 2 to donate through C4Q's webpage."
      end
    }

    p5 = Proc.new {
      donor.pledges.first.update_attribute(:payment, params[:Body])
      if (donor.pledges.first.payment == 1 || donor.pledges.first.payment == "1")
        donor.update_attribute(:steps, 1)
        response = Twilio::TwiML::Response.new do |r|
          r.Message "Please visit https://venmo.com to send @c4qnyc your pledge amount. Thanks for your contribution and enjoy the rest of your evening!"
        end
      elsif (donor.pledges.first.payment == 2 || donor.pledges.first.payment == "2")
        donor.update_attribute(:steps, 1)
        response = Twilio::TwiML::Response.new do |r|
          r.Message "Please visit http://c4q.nyc/donate. Thanks for your contribution and enjoy the rest of your evening!"
        end
      else
        raise "Invalid choice"
      end
    }

    p6 = Proc.new {
      donor.update_attribute(:email, params[:Body])
      donor.update_attribute(:steps, (donor.steps + 2))
      response = Twilio::TwiML::Response.new do |r|
        r.Message "The C4Q team will follow up with you to fulfill your pledge. Thank you for your generous support."
      end
    }

    p7 = Proc.new {
      amount = params[:Body].gsub("$", "").gsub(",", "").gsub("-", "")
      raise "Invalid amount type" if amount.to_i == 0
      pledge = SmsPledge.create(amount: amount.to_f)
      donor.update_attribute(:steps, 2)
      d.pledges << pledge
      response = Twilio::TwiML::Response.new do |r|
        r.Message "Thanks for pledging again! The C4Q team will follow up with you to fulfill your pledge."
      end
    }
    p8 = Proc.new {
      amount = params[:Body].gsub("$", "").gsub(",", "").gsub("-", "")
      raise "Invalid amount type" if amount.to_i == 0
      pledge = SmsPledge.create(amount: amount.to_f)
      donor.update_attribute(:steps, 1)
      d.pledges << pledge
      response = Twilio::TwiML::Response.new do |r|
        r.Message "Thanks for pledging again! How would you like to fulfill your pledge? Reply 1 for Venmo instructions. Reply 2 to donate through C4Q's webpage."
      end
    }


    [p1, p2, p3, p4, p5, p6][idx].call
  end

  def donor
    @donor if defined?(@donor)
    SmsDonor.where(phone_number: params[:From]).last
  end

end
