class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_friends, only: [:index]

  FIRST_RECOMMENDATION_COUNT = 5

  def index
  	# show friends recommendation
    @recommendations = Recommendation.get_friend_recommedations(@registered_friends)

    @friend_recommendations = []
    @yelp_names = []

    @recommendations.each do |recommendation|
      friend = User.find(recommendation.user)
      hash = {:name => friend.full_name, :fb_id => friend.identity.uid, :image => @graph.get_picture(friend.identity.uid),
        :friendId => friend.id }
      @friend_recommendations.push(hash)

      yelp = Restaurant.find(recommendation.restaurant_id).name
      @yelp_names.push(yelp)
    end

    # address to show on top
    @default_address = current_user.primary_address

    # in case the user has come to the site for the first time
    if session[:first_login] && session[:first_login] == true
      session[:first_login] = false
      @restaurants = Restaurant.get_results_from_google_places("", current_user)
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

    @homePage = true
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
    def set_friends
      identity = current_user.identity
      @graph = Koala::Facebook::API.new(identity.token)
      @friends = @graph.get_connections("me", "friends")
      friends_ids = []
      @friends.each do |friend|
        friends_ids << friend["id"]
      end

      @registered_friends = Identity.where(:provider => 'facebook') \
                                          .where('uid IN (?)', friends_ids).collect(&:user_id)
    end
end
