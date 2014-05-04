class AddAttachmentPicturesToRecommendations < ActiveRecord::Migration
  def self.up
    change_table :recommendations do |t|
      t.attachment :pictures
    end
  end

  def self.down
    drop_attached_file :recommendations, :pictures
  end
end
