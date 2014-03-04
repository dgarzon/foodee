 # construct a client instance
# include Yelp::V1::Review::Request
include Yelp::V2::Search::Request

require 'json'

class Restaurant < ActiveRecord::Base
	def Restaurant.get_restaurant_by_address
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
 		request = Location.new(
			:term => "german food",
			:address => "Hayes",
			:latitude => 37.77493,
			:longitude => -122.419415,
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
end
