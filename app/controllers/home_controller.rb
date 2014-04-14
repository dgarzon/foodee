class HomeController < ApplicationController
  before_filter :authenticate_user!

  FIRST_RECS_COUNT = 5

  def index
  	# show friends recommendation
    @recommendations = Recommendation.get_friend_recommedation(session[:friends])
    if @recommendations.empty?
      logger.debug "recommendations is empty"
    end

    # get ids of friend, restaurant
    @friendsFoundIds = []
    @yelpRestaurantNames = []
    @profilePicUrls = []
    @graph = Koala::Facebook::GraphAPI.new

    @recommendations.each do |recommendation|
      fb_id = User.find(recommendation.user_id).fb_id
      @friendsFoundIds << fb_id
      # also get the picture
      @profilePicUrls << @graph.get_picture(fb_id)

      @yelpRestaurantNames << Restaurant.find(recommendation.restaurant_id).name
    end
    @friendsFound = @graph.get_objects(@friendsFoundIds)

    # address to show on top
    @defaultAddress = current_user.primary_address()
    # used for restaurant search
    @address = Address.new

    # in case the user has come to the site for the first time
    logger.debug "client : #{current_user.sign_in_count.inspect}"
    if session[:firstLogin] && session[:firstLogin] == true
      session[:firstLogin] = false
      @formRecommendations = []
      @temp_restaurants = []
      @firstFewRestaurants = []
      @firstRestaurants = Restaurant.get_restaurant_by_query("", current_user)
      @firstRestaurants = @firstRestaurants['businesses']
      # logger.debug "client : #{@firstRestaurants.inspect}"

      # create these many forms
      i = 0
      @firstRestaurants.each do |restaurant|
        temp_restaurant = Restaurant.new
        temp_restaurant[:name] = restaurant["name"]
        temp_restaurant[:yelp_restaurant_id] = restaurant['id']
        @temp_restaurants << temp_restaurant

        recommendation = Recommendation.new
        recommendation[:user_id] = current_user[:id]
        # like by default
        recommendation[:like] = true
        @formRecommendations << recommendation
        @firstFewRestaurants << restaurant
        # top 5 restaurants
        if i > FIRST_RECS_COUNT
          break
        end
        i = i + 1
      end
    end

    @cuisines = ["African", "American", "Argentinian", "Bagels",
                 "BBQ", "Belgian", "Brazilian", "Burgers", "Cajun",
                 "Caribbean", "Chinese", "Cuban", "Deli", "Diner",
                 "English", "Filipino", "German", "Greek", "Halal",
                 "Healthy", "Indian", "Italian", "Korean", "Kosher",
                 "Peruvian", "Pizza", "Russian", "Salads", "Sandwiches",
                 "Smoothies", "Southern", "Spanish", "Steakhouse",
                 "Sushi", "Thai", "Turkish", "Vegan", "Vegetarian",
                 "Venezuelan", "Vietnamese"]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def searchAtAddress
    # send along the address received as parameter
    @geoCodedAddress = Address.new(@address)
    redirect_to restaurants_path(:address => @geoCodedAddress)
  end
end
