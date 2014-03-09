# == Schema Information
#
# Table name: addresses
#
#  id           :integer          not null, primary key
#  full_address :string(255)
#  street       :string(255)
#  city         :string(255)
#  state        :string(255)
#  country      :string(255)
#  latitude     :float
#  longitude    :float
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Address < ActiveRecord::Base
  belongs_to :user

  geocoded_by :full_address   # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates

  def full_address=(value)
    write_attribute(:full_address, value)
    full = value.split(", ")
    write_attribute(:street, full[0])
    write_attribute(:city, full[1])
    write_attribute(:state, full[2])
    write_attribute(:country, full[3])
  end

end
