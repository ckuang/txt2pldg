class SmsDonor < ActiveRecord::Base

  has_many :messages, foreign_key: "sms_donor_id", class_name: "SmsDonorMessage", dependent: :destroy
  has_many :pledges, foreign_key: "sms_donor_id", class_name: "SmsPledge", dependent: :destroy

  def self.create_from_twilio_response(params)
    donor = SmsDonor.create(
      phone_number: params[:From],
    )
    donor
  end

end
