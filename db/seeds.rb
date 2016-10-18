# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
charles = SmsDonor.create!(name: "Charles Kuang", phone_number: "+17182884033", email: "ckuang@c4q.nyc")
harry = SmsDonor.create!(name: "Harry Chiu", phone_number: "+13479924990", email: "harry@c4q.nyc")


pledge1 = SmsPledge.create!(sms_donor_id: 1, amount: 20, message: "")
pledge2 = SmsPledge.create!(sms_donor_id: 2, amount: 50, message: "")
