class AddPicsToRecommendations < ActiveRecord::Migration
  def change
  	add_attachment :recommendations, :pics
  end
end
