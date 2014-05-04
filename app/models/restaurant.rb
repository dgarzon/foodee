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

	def self.get_restaurant_by_cuisine (cuisine, user)
		client = Yelp::Client.new(:debug => false)
		request = Location.new(
		            :city => user.addresses.first.city,
		            :state => user.addresses.first.state,
		            :category => ['restaurant'],
		            :term => cuisine)
		response = client.search(request)
	end

	# http://api.yelp.com/v2/business/yelp-san-francisco
	def self.get_restaurant_by_yelp_id (yelp_id)
		client = Yelp::Client.new(:debug => false)
		request = Id.new(:yelp_business_id => yelp_id)
		response = client.search(request)
 		response
	end

	def self.get_venue_from_foursquare (query, address, city)
		geo = Geocoder.search(address + ", " + city)
		client = Foursquare2::Client.new(:api_version => '20131016', :client_id => 'GEFFG1OE4CDNJMT5LH4AU54SH2NL31HIY5EXU0AVHDLUJZY3', :client_secret => 'EBXY34DUC0DEBOBBEP4KCUH5QSGBP1TCQPRH24N3KAWV3L0E')
		venue = client.search_venues(:ll => "#{geo.first.data['geometry']['location']['lat']}" + ", " + "#{geo.first.data['geometry']['location']['lng']}", :query => query, :limit => 1)
		venue
	end

	def self.get_venue_tips_from_foursquare (foursquare_id)
		client = Foursquare2::Client.new(:api_version => '20131016', :client_id => 'GEFFG1OE4CDNJMT5LH4AU54SH2NL31HIY5EXU0AVHDLUJZY3', :client_secret => 'EBXY34DUC0DEBOBBEP4KCUH5QSGBP1TCQPRH24N3KAWV3L0E')
		tips = client.venue_tips(foursquare_id)
		tips
	end

	def self.get_venue_by_foursquare_id (foursquare_id)
		client = Foursquare2::Client.new(:api_version => '20131016', :client_id => 'GEFFG1OE4CDNJMT5LH4AU54SH2NL31HIY5EXU0AVHDLUJZY3', :client_secret => 'EBXY34DUC0DEBOBBEP4KCUH5QSGBP1TCQPRH24N3KAWV3L0E')
		venue = client.venue(foursquare_id)
		venue
	end

	def self.get_venue_foursquare_id(yelp_id)
		yelp = self.get_restaurant_by_yelp_id(yelp_id)
		foursquare = self.get_venue_from_foursquare(yelp['name'], yelp['location']['address'][0].to_s,  yelp['location']['city'].to_s)
		foursquare_id = foursquare.venues[0].id
		foursquare_id
	end

	def self.get_restaurant_google_places(query, address, city)
		# :zagatselected => 'true'
		geo = Geocoder.search(address + ", " + city)
		lat = geo.first.data['geometry']['location']['lat']
		lng = geo.first.data['geometry']['location']['lng']
		@client = GooglePlaces::Client.new("AIzaSyCW-Nfj4s92dzWLb232aPby6Bel7w3JT7g")
		# get the reference number from the search query
		spots = @client.spots(lat, lng, :keyword => query, :types => 'restaurant')
		# get the exact details from the details query
		spot = @client.spot(spots[0]["reference"])

		#logger.debug spot
		spot
	end
end
