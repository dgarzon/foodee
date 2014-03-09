class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :full_address
      t.string :street
      t.string :city
      t.string :state
      t.string :country

      t.float :latitude
      t.float :longitude

      t.references :user, index: true

      t.timestamps
    end
  end
end
