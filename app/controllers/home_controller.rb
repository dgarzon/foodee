class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
  	@search = Address.new
  end

  def searchAtAddress
    # send along the address received as parameter
    redirect_to restaurants_path(:address => @search)
  end
end
