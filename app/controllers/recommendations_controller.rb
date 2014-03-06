class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: [:show, :edit, :update, :destroy]

  # GET /recommendations
  # GET /recommendations.json
  def index
    @recommendations = Recommendation.all
  end

  # GET /recommendations/1
  # GET /recommendations/1.json
  def show
  end

  # GET /recommendations/new
  def new
    @recommendation = Recommendation.new
    @recommendation[:restaurant_id] = params[:restaurant_id]
    @recommendation[:user_id] = current_user[:id]
    # logger.debug "request : #{current_user.inspect}"

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /recommendations/1/edit
  def edit
  end

  # POST /recommendations
  # POST /recommendations.json
  def create
    # first add the restaurant
    @restaurant = Restaurant.new
    @restaurant[:yelp_restaurant_id] = recommendation_params[:restaurant_id]

    if @restaurant.save
      @restaurantSaved = true
    end

    @recommendation = Recommendation.new(recommendation_params)
    @recommendation[:restaurant_id] = @restaurant[:id]
    logger.debug "rec : #{@recommendation.inspect}"
    logger.debug "res : #{@restaurant.inspect}"

    respond_to do |format|
      if @restaurantSaved && @recommendation.save
        format.html { redirect_to @recommendation, notice: 'Recommendation was successfully created.' }
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
      params.require(:recommendation).permit(:like, :description, :user_id, :restaurant_id)
    end
end
