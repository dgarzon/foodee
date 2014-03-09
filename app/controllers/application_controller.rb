class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    resource.sign_in_count <= 1 ? new_user_address_path(resource) : home_index_path
  end

end
