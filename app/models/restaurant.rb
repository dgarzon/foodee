 # construct a client instance
# include Yelp::V1::Review::Request
include Yelp::V2::Search::Request
include Yelp::V2::Business::Request

require 'json'

class Restaurant < ActiveRecord::Base
	# added for reecommendations
	has_many :recommendation, dependent: :destroy
	
	def Restaurant.get_restaurant_by_address(address)
		client = Yelp::Client.new(
			:debug => true)
		# logger.debug "client : #{client.inspect}"
		# request = Location.new(
  #            :address => '650 Mission St',
  #            :city => 'San Francisco',
  #            :state => 'CA',
  #            :radius => 2,
  #            :term => 'cream puffs')
		# request = Location.new(
  #            :term => "german food",
  #            :address => "Hayes",
  #            :latitude => 37.77493,
  #            :longitude => -122.419415)
 		# request = Location.new(
			# :term => "german food",
			# :address => "Hayes",
			# :latitude => 37.77493,
			# :longitude => -122.419415,
			# :yws_id          => 'Aa2e8aMm9ZdHOiiI164WSw',
			# :consumer_key    => 'kDDqnlb0xWWYy0FDZseYtQ',
			# :consumer_secret => '2sxOlWVTLU-w0y5am2PwBYJgYfg',
			# :token           => 'nXrZg_uXt8gX27UIXd7RncJFO9Jm3asd',
			# :token_secret    => 'ZKU9o91pBJ45kbFSwcClx0wlxxQ')
 		request = Location.new(
			:address => address,
			:term => "food",
			:yws_id          => 'Aa2e8aMm9ZdHOiiI164WSw',
			:consumer_key    => 'kDDqnlb0xWWYy0FDZseYtQ',
			:consumer_secret => '2sxOlWVTLU-w0y5am2PwBYJgYfg',
			:token           => 'nXrZg_uXt8gX27UIXd7RncJFO9Jm3asd',
			:token_secret    => 'ZKU9o91pBJ45kbFSwcClx0wlxxQ')
 		
		# logger.debug "request : #{request.inspect}"
		response = client.search(request)
		# logger.debug "reponse : #{response.inspect}"
		# response is a Ruby hash
		response
	end

	# http://api.yelp.com/v2/business/yelp-san-francisco
	def Restaurant.get_restaurant_by_yelp_id(yelp_restaurant_id)
		client = Yelp::Client.new(
			:debug => true)
		# retrieve details of business vi yelp business id
		request = Id.new(
		            :yelp_business_id => yelp_restaurant_id,
		            :yws_id          => 'Aa2e8aMm9ZdHOiiI164WSw',
					:consumer_key    => 'kDDqnlb0xWWYy0FDZseYtQ',
					:consumer_secret => '2sxOlWVTLU-w0y5am2PwBYJgYfg',
					:token           => 'nXrZg_uXt8gX27UIXd7RncJFO9Jm3asd',
					:token_secret    => 'ZKU9o91pBJ45kbFSwcClx0wlxxQ')
		response = client.search(request)
 		response
	end
end
