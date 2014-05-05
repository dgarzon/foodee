 # construct a client instance
# include Yelp::V1::Review::Request
include Yelp::V2::Search::Request
include Yelp::V2::Business::Request

require 'json'

class Restaurant < ActiveRecord::Base
	has_many :recommendation, dependent: :destroy

	def self.get_results_from_google_places(query, user, flag = false)
		if query.empty?
			term = "restaurants"
			address = ""
		elsif !flag
			term = query[0]
			address = query[1..-1].join(", ")
		else
			term = query
			address = ""
		end
		geo = Geocoder.search(address)
		client = GooglePlaces::Client.new("AIzaSyB8fUZUPNYIWKwz6Nss-Hu7J_2VUjFSOWA")
		if geo.empty?
			search = term + ' near ' + user.addresses.first.city + ', ' + user.addresses.first.state
			spots = client.spots_by_query(search, :types => ['restaurant', 'food'])
		else
			lat = geo.first.data['geometry']['location']['lat']
			lng = geo.first.data['geometry']['location']['lng']
			spots = client.spots(lat, lng, :keyword => term, :types => ['restaurant', 'food'])
		end

		response = []
		spots.each_with_index do |spot, index|
			yelp = self.get_spot_yelp_data(spot)

			self.create_spot_attribute(spot, "yelp_id")
			self.create_spot_attribute(spot, "yelp_rating")

	    spot.yelp_id = yelp[:yelp_id]

	    if !yelp[:yelp_rating].nil?
	    	spot.yelp_rating = yelp[:yelp_rating]
	    else
	    	spot.yelp_rating = 0.0
	    end

	    foursquare = self.get_spot_foursquare_data(spot)

  		self.create_spot_attribute(spot, "foursquare_id")
  		self.create_spot_attribute(spot, "foursquare_rating")

      spot.foursquare_id = foursquare[:foursquare_id]

      if !foursquare[:foursquare_rating].nil?
      	spot.foursquare_rating = (foursquare[:foursquare_rating]/2).round(1)
      else
      	spot.foursquare_rating = 0.0
      end

      self.create_spot_attribute(spot, "weighted_rating")

      if !spot.rating.nil?
      	spot.weighted_rating = ((spot.foursquare_rating + spot.yelp_rating + spot.rating) / 3).round(1)
      else
      	spot.rating = 0.0
      	spot.weighted_rating = ((spot.foursquare_rating + spot.yelp_rating + spot.rating) / 3).round(1)
      end
		end

		spots
	end

	def self.create_spot_method( spot, name, &block )
	    spot.class.send( :define_method, name, &block )
	end

	def self.create_spot_attribute( spot, name )
	    create_spot_method( spot, "#{name}=".to_sym ) { |val|
	        instance_variable_set( "@" + name, val)
	    }

	    create_spot_method( spot, name.to_sym ) {
	        instance_variable_get( "@" + name )
	    }
	end

	def self.get_spot_yelp_data (spot)
		client = Yelp::Client.new(:debug => false)
		logger.debug spot.inspect

		if spot.vicinity.nil? && !spot.formatted_address.nil?
			params = { :term => spot.name,
		             :address => spot.formatted_address,
		             :latitude => spot.lat,
		             :longitude => spot.lng,
		             :limit => 1}
		else
			params = { :term => spot.name,
		             :address => spot.vicinity,
		             :latitude => spot.lat,
		             :longitude => spot.lng,
		             :limit => 1}
    end
	  request = Location.new(params)
	  response = client.search(request)

	  data = {:yelp_id => response["businesses"][0]["id"], :yelp_rating => response["businesses"][0]["rating"]}
	end

	def self.get_spot_foursquare_data (spot)
		client = Foursquare2::Client.new(:api_version => '20131016', :client_id => 'GEFFG1OE4CDNJMT5LH4AU54SH2NL31HIY5EXU0AVHDLUJZY3', :client_secret => 'EBXY34DUC0DEBOBBEP4KCUH5QSGBP1TCQPRH24N3KAWV3L0E')
		search = client.search_venues(:ll => "#{spot.lat}" + ", " + "#{spot.lng}", :query => spot.name, :limit => 1)
		venue = client.venue(search.venues[0][:id])

		data = {:foursquare_id => venue[:id], :foursquare_rating => venue[:rating]}
	end

	# http://api.yelp.com/v2/business/yelp-san-francisco
	def self.get_restaurant_reviews_from_yelp (yelp_id)
		client = Yelp::Client.new(:debug => false)
		request = Id.new(:yelp_business_id => yelp_id)
		response = client.search(request)
 		response["reviews"]
	end

	def self.get_venue_tips_from_foursquare (foursquare_id)
		client = Foursquare2::Client.new(:api_version => '20131016', :client_id => 'GEFFG1OE4CDNJMT5LH4AU54SH2NL31HIY5EXU0AVHDLUJZY3', :client_secret => 'EBXY34DUC0DEBOBBEP4KCUH5QSGBP1TCQPRH24N3KAWV3L0E')
		tips = client.venue_tips(foursquare_id)
		tips
	end


	def self.get_place_from_google (google_id)
		@client = GooglePlaces::Client.new("AIzaSyB8fUZUPNYIWKwz6Nss-Hu7J_2VUjFSOWA")
		spot = @client.spot(google_id)
		spot
	end
end
