class RestaurantsController < ApplicationController
  # before_action :set_restaurant, only: [:edit, :update, :destroy]

  # GET /restaurants
  # GET /restaurants.json
  def index
    if !params[:cuisine]
      query = params[:search][:term].split(",")
      result = Restaurant.get_restaurant_by_query(query, current_user)
      @restaurants = result['businesses']
    else
      query = params[:cuisine]
      result = Restaurant.get_restaurant_by_cuisine(query, current_user)
      @restaurants = result['businesses']
    end

    # so that we render the links only when we have recommendations from friends
    @recsFoundIds = []
    @restaurants.each do |restaurant|
      # logger.debug "rest : #{restaurant["location"]["address"].inspect}"
        recommendations = Recommendation.get_friend_recommedation_by_restaurant(restaurant["id"], session[:friends])
        if recommendations.empty?
          @recsFoundIds << false
        else
          @recsFoundIds << true
        end
    end
  end

  # GET /restaurants/1
  # GET /restaurants/1.json
  def show
    dbRestaurant = Restaurant.find(params[:id])
    @restaurant = Restaurant.get_restaurant_by_yelp_id dbRestaurant.yelp_restaurant_id
  end

  # GET /restaurants/new
  def new
    @restaurant = Restaurant.new
  end

  # GET /restaurants/1/edit
  def edit
  end

  def recommendations
    if params[:external]
      # adding yelp reviews
      @restaurant = Restaurant.get_restaurant_by_yelp_id params[:restaurant_id]
      @reviews = @restaurant["reviews"]

      # adding foursquare tips
      @venue = Restaurant.get_venue_from_foursquare params[:restaurant_name], params[:restaurant_address], params[:restaurant_city]
      @tips = Restaurant.get_venue_tips_from_foursquare @venue.venues[0].id

      logger.debug @tips
    else
      # show friends recommendation
      @recommendations = Recommendation.get_friend_recommedation_by_restaurant(params[:restaurant_id], session[:friends])
      # get details on friend
      @friendsFoundIds = []
      @profilePicUrls = []
      @graph = Koala::Facebook::GraphAPI.new

      @recommendations.each do |recommendation|

        fb_id = User.find(recommendation.user_id).fb_id
        @friendsFoundIds << fb_id
        # also get the picture
        @profilePicUrls << @graph.get_picture(fb_id)
      end
      # get their details
      # @graph = Koala::Facebook::API.new(identity.token)

      @friendsFound = @graph.get_objects(@friendsFoundIds)
    end

    respond_to do |format|
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def restaurant_params
      params.permit(:restaurant, :name, :location, :term)
    end
end
