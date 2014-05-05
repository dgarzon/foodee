class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:edit, :update, :destroy]
  before_action :set_friends, only: [:index, :recommendations]

  # GET /restaurants
  # GET /restaurants.json
  def index
    if !params[:cuisine]
      query = params[:search][:term].split(",")
      result = Restaurant.get_results_from_google_places(query, current_user)
      @restaurants = result
    else
      query = params[:cuisine]
      result = Restaurant.get_results_from_google_places(query, current_user, true)
      @restaurants = result
    end

    # so that we render the links only when we have recommendations from friends
    @found_recommendations = []
    @restaurants.each do |restaurant|
      recommendations = Recommendation.get_friend_recommedation_by_restaurant(restaurant["id"], @registered_friends)
      if recommendations.empty?
        @found_recommendations << false
      else
        @found_recommendations << true
      end
    end
  end

  # GET /restaurants/1
  # GET /restaurants/1.json
  def show
    @google_place = Restaurant.get_place_from_google params[:google_id]
    @yelp_reviews = Restaurant.get_restaurant_reviews_from_yelp params[:yelp_id]
    @foursquare_tips = Restaurant.get_venue_tips_from_foursquare params[:foursquare_id]
    @google_reviews = @google_place.reviews
    @google_images = []
    @google_reviews.each do |review|
      str = review.author_url.to_s
      google_plus_id =  str[24..-1]
      request = "https://www.googleapis.com/plus/v1/people/" + "#{google_plus_id}" + "?fields=image&key=AIzaSyCW-Nfj4s92dzWLb232aPby6Bel7w3JT7g"
      response = HTTParty.get(request)
      result = JSON.parse(response.body)

      if result["image"]
        @google_images << result["image"]["url"]
      else
        @google_images << nil
      end
    end
    @friend_recommendations = Recommendation.get_friend_recommedation_by_restaurant(params[:google_id], @registered_friends)
  end

  # GET /restaurants/new
  def new
    @restaurant = Restaurant.new
  end

  # GET /restaurants/1/edit
  def edit
  end

  def recommendations
    # if params[:external]
      # adding yelp reviews
      # show friends recommendation
      # @recommendations = Recommendation.get_friend_recommedation_by_restaurant(params[:restaurant_id], @registered_friends)
      # @friend_recommendations = []
      # @recommendations.each do |recommendation|
      #   friend = User.find(recommendation.user_id)
      #   hash = {:name => friend.full_name, :fb_id => friend.identity.uid, :image => @graph.get_picture(friend.identity.uid)}
      #   @friend_recommendations.push(hash)
      # end
    # end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /restaurants
  # POST /restaurants.json
  def create
    @restaurant = Restaurant.new(restaurant_params)

    respond_to do |format|
      if @restaurant.save
        format.html { redirect_to @restaurant, notice: 'Restaurant was successfully created.' }
        format.json { render action: 'show', status: :created, location: @restaurant }
      else
        format.html { render action: 'new' }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /restaurants/1
  # PATCH/PUT /restaurants/1.json
  def update
    respond_to do |format|
      if @restaurant.update(restaurant_params)
        format.html { redirect_to @restaurant, notice: 'Restaurant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /restaurants/1
  # DELETE /restaurants/1.json
  def destroy
    @restaurant.destroy
    respond_to do |format|
      format.html { redirect_to restaurants_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_restaurant
      @restaurant = Restaurant.find(params[:id])
    end

    def set_friends
      identity = current_user.identity
      @graph = Koala::Facebook::API.new(identity.token)
      @friends = @graph.get_connections("me", "friends")
      friends_ids = []
      @friends.each do |friend|
        friends_ids << friend["id"]
      end

      @registered_friends = Identity.where(:provider => 'facebook') \
                                          .where('uid IN (?)', friends_ids).collect(&:uid)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def restaurant_params
      params.permit(:restaurant, :name, :location, :term)
    end
end
