class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :restaurant

  # for paperclip
  # This method associates the attribute ":pictures" with a file attachment
  has_attached_file :pictures,
  styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  },
  :storage => :s3,
  :bucket => ENV['AWS_BUCKET'],
  :s3_credentials => {
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :pictures, :content_type => /\Aimage\/.*\Z/

  def self.get_friend_recommedation_by_restaurant(yelp_id, friend_id)
  	recommendation = Recommendation.where(user_id: User.select("id").where(id: friend_id),
  		restaurant_id: Restaurant.select("id").where(yelp_id: yelp_id))
    recommendation

  end

  def self.get_friend_recommedations(friends)
    recommendation = Recommendation.where(user_id: User.select("id").where(id: friends))
    recommendation
  end

  def self.get_my_recommedation(id)
    recommendation = Recommendation.where(user_id: id)
    recommendation
  end

  def self.get_my_recommedation_by_restaurant(user_id, yelp_id)
    recommendation = Recommendation.where(user_id: user_id, restaurant_id: Restaurant.select("id").where(yelp_id: yelp_id))
    recommendation
  end

end
