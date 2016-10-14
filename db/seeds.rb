# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
charles = SmsDonor.create!(name: "Jukay Hsu", phone_number: "7182256718", email: "ckuang@c4q.nyc")
will = SmsDonor.create!(name: "Dave Yang", phone_number: "325123553", email: "will@c4q.nyc")


pledge1 = SmsPledge.create!(sms_donor_id: 1, amount: 1000, message: "🍔")
pledge2 = SmsPledge.create!(sms_donor_id: 2, amount: 2500, message: "🍟")
