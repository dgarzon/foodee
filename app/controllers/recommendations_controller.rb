class RecommendationsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_recommendation, only: [:edit, :update, :destroy]

  # GET /recommendations
  # GET /recommendations.json
  def index
    @recommendations = Recommendation.get_my_recommedation(current_user.id)
  end

  # GET /recommendations/1
  # GET /recommendations/1.json
  def show
    # show friends recommendation
    @recommendations = Recommendation.get_friend_recommedation_by_restaurant(params[:id], session[:friends])
    # get details on friend
    @friendsFoundIds = []
    @recommendations.each do |recommendation|

      fb_id = User.find(recommendation.user_id).fb_id
      @friendsFoundIds << fb_id
    end
    # get their details
    # @graph = Koala::Facebook::API.new(identity.token)
    @graph = Koala::Facebook::GraphAPI.new
    @friendsFound = @graph.get_objects(@friendsFoundIds)

    # adding yelp reviews
    @restaurant = Restaurant.get_restaurant_by_yelp_id params[:id]
    @yelpReviews = @restaurant["reviews"]
    logger.debug "client : #{@yelpReviews.inspect}"

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

  # POST /recommendations
  # POST /recommendations.json
  def create
    @recommendation = current_user.recommendations.new

    restaurant = Restaurant.where(:yelp_restaurant_id => params[:recommendation][:restaurant_id], :name => params[:recommendation][:restaurant_name]).first

    if restaurant.nil?
      restaurant = Restaurant.new(:yelp_restaurant_id => params[:recommendation][:restaurant_id], :name => params[:recommendation][:restaurant_name])
      restaurant.save!
    end

    @recommendation.description = params[:recommendation][:description]
    @recommendation.like = true
    @recommendation.pics = params[:recommendation][:pics]
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def recommendation_params
      params.require(:recommendation).permit(:like, :description, :user_id, :restaurant_id, :restaurant_name, :pics)
    end
  end
