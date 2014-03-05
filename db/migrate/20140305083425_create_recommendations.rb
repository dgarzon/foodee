class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.boolean :like
      t.string :description
      t.belongs_to :user, index: true
      t.belongs_to :restaurant, index: true

      t.timestamps
    end
  end
end
