class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  def after_sign_in_path_for(resource)
    home_index_path
  end

  def after_sign_up_path_for(resource)
    new_user_address_path(resource)
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_address_path(resource)
  end

end
