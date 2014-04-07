class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :restaurant

  # for paperclip
  # This method associates the attribute ":pics" with a file attachment
  has_attached_file :pics, 
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
  validates_attachment_content_type :pics, :content_type => /\Aimage\/.*\Z/

  def Recommendation.get_friend_recommedation_by_restaurant(yelp_restaurant_id, friendIds)

  	# Recommendation.where(["restaurant_id = :id and email = :email", { id: restaurant_id, email: friendIds }])
  	# Recommendation.joins(:users).on(users[:fb_id].eq(recommendations[:user_id]))
  	# Recommendation.joins(:users).where(orders: {created_at: time_range})
  	Recommendation.where(user_id: User.select("id").where(fb_id: friendIds), 
  		restaurant_id: Restaurant.select("id").where(yelp_restaurant_id: yelp_restaurant_id))
	# select("recommendations.id, recommendations.like, recommendations.description, users.fb_id, restaurants.name")
	
  	# Recommendation.includes(:restaurants, :users).where("recommendations.user_id = ?", User.select("id").where(fb_id: friendIds)
  	# 	"recommendations.restaurant_id = ?", Restaurant.select("id").where(yelp_restaurant_id: yelp_restaurant_id))
  end

  def Recommendation.get_friend_recommedation(friendIds)
    Recommendation.where(user_id: User.select("id").where(fb_id: friendIds))
  end

  def Recommendation.get_my_recommedation(id)
    Recommendation.where(user_id: id)
  end
end
