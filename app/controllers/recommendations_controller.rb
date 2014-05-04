class RecommendationsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_recommendation, only: [:edit, :update, :destroy]
  before_action :set_friends, only: [:show, :newsFeed]

  # GET /recommendations
  # GET /recommendations.json
  def index
    @recommendations = Recommendation.get_my_recommedation(current_user.id)
  end

  # GET /recommendations/1
  # GET /recommendations/1.json
  def show
    @recommendations = Recommendation.get_friend_recommedation_by_restaurant(params[:restaurant_id], @registered_friends)
    @friend_recommendations = []
    @recommendations.each do |recommendation|
      friend = User.find(recommendation.user)
      hash = {:name => friend.full_name, :fb_id => friend.identity.uid, :image => @graph.get_picture(friend.identity.uid)}
      @friend_recommendations.push(hash)
    end

    # adding yelp reviews
    recommendation = Recommendation.where(:id => params[:id]).first

    @restaurant = Restaurant.get_restaurant_by_yelp_id recommendation.restaurant.yelp_id
    @reviews = @restaurant["reviews"]

    @venue = Restaurant.get_venue_by_foursquare_id recommendation.restaurant.foursquare_id
    @tips = Restaurant.get_venue_tips_from_foursquare recommendation.restaurant.foursquare_id

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /recommendations/new
  def new
    @recommendation = current_user.recommendations.build
  end

  # GET /recommendations/1/edit
  def edit
  end

  # GET /recommendations/2/friendProfile
  def friendProfile
    #logger.debug params
    @friend = User.find(params[:recommendation_id])
    @recommendations = Recommendation.get_my_recommedation(params[:recommendation_id])
    @fbId = params[:fbId]
  end

  # GET /recommendations/newsFeed
  def newsFeed
    # show friends recommendation
    @recommendations = Recommendation.get_friend_recommedations(@registered_friends)

    @friend_recommendations = []
    @recommendations.each do |recommendation|
      friend = User.find(recommendation.user)
      hash = {:name => friend.full_name, :fb_id => friend.identity.uid, :image => @graph.get_picture(friend.identity.uid),
        :friendId => friend.id }
      @friend_recommendations.push(hash)
    end
    
    logger.debug @recommendations.count
  end

  # POST /recommendations
  # POST /recommendations.json
  def create
    @recommendation = current_user.recommendations.new

    restaurant = Restaurant.where(:yelp_id => params[:recommendation][:yelp_id], :foursquare_id => params[:recommendation][:foursquare_id], :google_id => params[:recommendation][:google_id]).first

    if restaurant.nil?
      restaurant = Restaurant.new(:yelp_id => params[:recommendation][:yelp_id], :foursquare_id => params[:recommendation][:foursquare_id], :google_id => params[:recommendation][:google_id], :name => params[:recommendation][:name], :location => params[:recommendation][:location])
      restaurant.save!
    end

    @recommendation.description = params[:recommendation][:description]
    @recommendation.like = true
    @recommendation.pictures = params[:recommendation][:pictures]
    @recommendation.restaurant_id = restaurant.id

    respond_to do |format|
      if @recommendation.save
        format.html { redirect_to action: "index", notice: 'Recommendation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @recommendation }
      else
        format.html { render action: 'new' }
        format.json { render json: @recommendation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recommendations/1
  # PATCH/PUT /recommendations/1.json
  def update
    respond_to do |format|
      if @recommendation.update(recommendation_params)
        format.html { redirect_to @recommendation, notice: 'Recommendation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @recommendation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recommendations/1
  # DELETE /recommendations/1.json
  def destroy
    @recommendation.destroy
    respond_to do |format|
      format.html { redirect_to recommendations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recommendation
      @recommendation = Recommendation.find(params[:id])
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
                                          .where('uid IN (?)', friends_ids).collect(&:user_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recommendation_params
      params.require(:recommendation).permit(:like, :description, :user_id, :restaurant_id, :restaurant_name, :pictures)
    end
  end
