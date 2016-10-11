class SmsPledge < ActiveRecord::Base
  belongs_to :donor, class_name: "SmsDonor", foreign_key: :sms_donor_id

  def as_json(options={})
    serializable_hash( options).merge({donor: donor.as_json})
  end
end
