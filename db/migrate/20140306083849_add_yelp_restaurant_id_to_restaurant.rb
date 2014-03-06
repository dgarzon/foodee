class AddYelpRestaurantIdToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :yelp_restaurant_id, :string
  end
end
