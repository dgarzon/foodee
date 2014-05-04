class WelcomeController < ApplicationController
  layout "welcome"

  def index
  	# added to hide search bar on home page
    @homePage = true
    if user_signed_in?
      redirect_to home_index_path
    end
  end

end
