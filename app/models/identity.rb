# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  uid        :string(255)
#  provider   :string(255)
#  token      :string(255)
#  secret     :string(255)
#  expires_at :datetime
#  email      :string(255)
#  image      :string(255)
#  nickname   :string(255)
#  first_name :string(255)
#  last_name  :string(255)
#  user_id    :integer
#

class Identity < ActiveRecord::Base
  belongs_to :user

  def self.from_omniauth(auth)
    identity = where(auth.slice(:provider, :uid)).first_or_create do |identity|
      identity.provider     = auth.provider
      identity.uid          = auth.uid
      identity.token        = auth.credentials.token
      identity.secret       = auth.credentials.secret if auth.credentials.secret
      identity.expires_at   = auth.credentials.expires_at if auth.credentials.expires_at
      identity.email        = auth.info.email if auth.info.email
      identity.image        = auth.info.image if auth.info.image
      identity.first_name   = auth.info.first_name
      identity.last_name    = auth.info.last_name
    end
    identity.save!

    if !identity.persisted?
      redirect_to root_url, alert: "Something went wrong, please try again."
    end
    identity
  end

  def find_or_create_user(current_user)
    if current_user && self.user == current_user
      # User logged in and the identity is associated with the current user
      return self.user
    elsif current_user && self.user != current_user
      # User logged in and the identity is not associated with the current user
      # so lets associate the identity and update missing info
      self.user = current_user
      self.user.email       ||= self.email
      self.user.image       ||= self.image
      self.user.first_name  ||= self.first_name
      self.user.last_name   ||= self.last_name
      self.user.fb_id   ||= self.uid

      self.user.skip_reconfirmation!
      self.user.save!
      self.save!
      return self.user
    elsif self.user.present?
      # User not logged in and we found the identity associated with user
      # so let's just log them in here
      return self.user
    else
      # No user associated with the identity so we need to create a new one
      self.build_user(
        email: self.email,
        image: self.image,
        first_name: self.first_name,
        last_name: self.last_name,
        fb_id:  self.uid
      )
      self.user.save!(validate: false)
      self.save!
      return self.user
    end
  end

end
