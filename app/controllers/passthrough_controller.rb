class PassthroughController < ApplicationController
  def index
    if user_signed_in?
      redirect_to home_index_path
    else
      redirect_to welcome_index_path
    end
  end
end
