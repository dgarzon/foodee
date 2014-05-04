class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :location
      t.string :yelp_id
      t.string :foursquare_id
      t.string :google_id

      t.timestamps
    end
  end
end
