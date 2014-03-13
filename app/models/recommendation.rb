class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :restaurant

  def Recommendation.get_recommedation_by_restaurant(restaurant_id, friendIds)

  	# Recommendation.where(["restaurant_id = :id and email = :email", { id: restaurant_id, email: friendIds }])
  	# Recommendation.joins(:users).on(users[:fb_id].eq(recommendations[:user_id]))
  	# Recommendation.joins(:users).where(orders: {created_at: time_range})
  	Recommendation.where(user_id: User.select("id").where(fb_id: friendIds), restaurant_id: restaurant_id)
  end
end
