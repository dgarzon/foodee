 # construct a client instance
# include Yelp::V1::Review::Request
include Yelp::V2::Search::Request
include Yelp::V2::Business::Request

require 'json'

class Restaurant < ActiveRecord::Base
	has_many :recommendation, dependent: :destroy

	def self.get_restaurant_by_query (query, user)
		if query.empty?
			term = "restaurants"
			address = ""
		else
			term = query[0]	
			address = query[1..-1].join(", ")
		end
		
		geo = Geocoder.search(address)
		client = Yelp::Client.new(:debug => false)

		if geo.empty?
			  request = Location.new(
									             :term => term,
									             :address => user.addresses.first.street,
		                           :city => user.addresses.first.city,
		                           :state => user.addresses.first.state,
		                           :radius => 4)
		else
			latitude = geo.first.data['geometry']['location']['lat']
			longitude = geo.first.data['geometry']['location']['lng']
		  request = Location.new(
								             :term => term,
								             :address => address,
								             :latitude => latitude,
								             :longitude => longitude,
								             :limit => 1)
		end

		response = client.search(request)
		response
	end

	# http://api.yelp.com/v2/business/yelp-san-francisco
	def self.get_restaurant_by_yelp_id (yelp_restaurant_id)
		client = Yelp::Client.new(:debug => false)
		request = Id.new(:yelp_business_id => yelp_restaurant_id)
		response = client.search(request)
 		response
	end
end
