class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def all
    identity = Identity.from_omniauth(request.env["omniauth.auth"])
    user = identity.find_or_create_user(current_user)

    if user.valid?
      if user.sign_in_count < 1
        flash[:success] = "Welcome to Foodee, #{user.first_name}!"
        sign_in user
        # to identify first visit of home page
        session[:first_login] = true
        redirect_to new_user_address_path(user)
      else
        flash[:success] = "Welcome back, #{user.first_name}!"
        sign_in_and_redirect user
      end
    else
      sign_in user
      redirect_to edit_user_registration_url
    end
  end

  alias_method :facebook, :all
end