 # construct a client instance
# include Yelp::V1::Review::Request
include Yelp::V2::Search::Request
include Yelp::V2::Business::Request

require 'json'

class Restaurant < ActiveRecord::Base
	has_many :recommendation, dependent: :destroy

	def self.get_restaurant_by_query (query)
		term = query[0]
		address = query[1..-1].join(", ")
		geo = Geocoder.search(address)
		latitude = geo.first.data['geometry']['location']['lat']
		longitude = geo.first.data['geometry']['location']['lng']

		client = Yelp::Client.new(:debug => true)
	  request = GeoPoint.new(
							             :term => term,
							             :latitude => latitude,
							             :longitude => longitude)
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
