class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index

  	# show friends recommendation
    @recommendations = Recommendation.get_friend_recommedation(session[:friends])
    # get ids of friend, restaurant
    @friendsFoundIds = []
    @yelpRestaurantNames = []
    @recommendations.each do |recommendation|
      fb_id = User.find(recommendation.user_id).fb_id
      @friendsFoundIds << fb_id

      @yelpRestaurantNames << Restaurant.find(recommendation.restaurant_id).name
    end
    @graph = Koala::Facebook::GraphAPI.new
    @friendsFound = @graph.get_objects(@friendsFoundIds)

    respond_to do |format|
      format.html
      format.js
    end
  end
end
