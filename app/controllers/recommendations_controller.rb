class RecommendationsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_recommendation, only: [:edit, :update, :destroy]

  # GET /recommendations
  # GET /recommendations.json
  def index
    # improve to query to join eagerly using include
    # @recommendations = Recommendation.find :all, :joins => :restaurant
    @recommendations = Recommendation.get_my_recommedation(current_user.id)
    # logger.debug "client : #{@recommendations.inspect}"
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

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /recommendations/new
  def new

    # logger.debug "request : #{current_user.inspect}"
    respond_to do |format|
      # user not signed in
      if current_user
        @recommendation = Recommendation.new
        @recommendation[:restaurant_id] = params[:restaurant_id]

        # setup a temp restaurant
        @temp_restaurant = Restaurant.new
        @temp_restaurant[:name] = params[:restaurant_name]

        @recommendation[:user_id] = current_user[:id]
        # like by default
        @recommendation[:like] = true

        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  # GET /recommendations/1/edit
  def edit
  end

  # POST /recommendations
  # POST /recommendations.json
  def create
    # logger.debug "client : #{params.inspect}"
    # logger.debug "client : #{params[:restaurant_name].inspect}"
    

    # first add the restaurant, if it doesnt exist
    @restaurant = Restaurant.find(:first, 
      :conditions => ["yelp_restaurant_id = ? ", recommendation_params[:restaurant_id]])

    if(@restaurant == nil)
      # new restaurant
      @restaurant = Restaurant.new
      @restaurant[:yelp_restaurant_id] = recommendation_params[:restaurant_id]
      @restaurant[:name] = recommendation_params[:restaurant_name]

      if @restaurant.save
        @restaurantSaved = true
      end
    else
      # old restaurant, already saved
      @restaurantSaved = true
    end

    # @recommendation = Recommendation.new(recommendation_params)
    @recommendation = Recommendation.new
    @recommendation[:like] = recommendation_params[:like]
    @recommendation[:description] = recommendation_params[:description]
    @recommendation[:user_id] = recommendation_params[:user_id]
    # added for images
    @recommendation.pics = recommendation_params[:pics]

    @recommendation[:restaurant_id] = @restaurant[:id]
    logger.debug "rec : #{@recommendation.inspect}"
    logger.debug "res : #{@restaurant.inspect}"

    respond_to do |format|
      if @restaurantSaved && @recommendation.save
        # format.html { redirect_to @recommendation, notice: 'Recommendation was successfully created.' }
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
