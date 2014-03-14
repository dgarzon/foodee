class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :restaurant

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
