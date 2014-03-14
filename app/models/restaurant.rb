 # construct a client instance
# include Yelp::V1::Review::Request
include Yelp::V2::Search::Request
include Yelp::V2::Business::Request

require 'json'

class Restaurant < ActiveRecord::Base
	# added for reecommendations
	has_many :recommendation, dependent: :destroy
<<<<<<< HEAD

	def self.get_restaurant_by_address (address, term)
		client = Yelp::Client.new(:debug => true)
	  request = GeoPoint.new(
							             :term => term,
							             :latitude => address.latitude,
							             :longitude => address.longitude)
		response = client.search(request)
		response
	end

	# http://api.yelp.com/v2/business/yelp-san-francisco
	def self.get_restaurant_by_yelp_id (yelp_restaurant_id)
		client = Yelp::Client.new(:debug => true)
		request = Id.new(:yelp_business_id => yelp_restaurant_id)
		response = client.search(request)
 		response
	end
end
