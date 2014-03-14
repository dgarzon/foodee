class RestaurantsController < ApplicationController
  # before_action :set_restaurant, only: [:edit, :update, :destroy]

  # GET /restaurants
  # GET /restaurants.json
  def index
    # @restaurants = Restaurant.all
    # supposed to have an address in the params
<<<<<<< HEAD
    logger.debug params[:search][:term]
    @restaurants = Restaurant.get_restaurant_by_address(current_user.addresses.first, params[:search][:term])
=======
    logger.debug "request : #{params[:address].inspect}"
    @restaurants = Restaurant.get_restaurant_by_address(params[:address][:full_address])
>>>>>>> b35f71d0b2768edaac1597d6dfaa40f33df8dbec
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
