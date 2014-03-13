class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def all
    identity = Identity.from_omniauth(request.env["omniauth.auth"])
    user = identity.find_or_create_user(current_user)

    if user.valid?
      user.sign_in_count <= 1 ? flash[:success] = "Welcome to Foodee, #{user.first_name}!" : flash[:notice] = "Welcome back, #{user.first_name}!"
      # need to get updated friends list here and save in current user session
      @graph = Koala::Facebook::API.new(identity.token)
      graphFriends = @graph.get_connections("me", "friends")
      # friendsArray = JSON.parse graphFriends
      # logger.debug "friends : #{friendsArray.inspect}"
      sessionFriends = []
      graphFriends.each do |friend|
        sessionFriends << friend["id"]
      end
      session[:friends] = sessionFriends

      # redirect to looged in page
      sign_in_and_redirect user
    else
      sign_in user
      redirect_to edit_user_registration_url
    end
  end

  alias_method :facebook, :all
end