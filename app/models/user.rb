# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  image                  :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ActiveRecord::Base
  # added for recommendations
  has_many :recommendation, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  extend FriendlyId

  friendly_id :username, use: [:slugged, :finders]
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_one :indentity, :dependent => :destroy

  has_many :addresses, :dependent => :destroy

  validates_presence_of :email, :first_name, :last_name

  before_create :ensure_username_uniqueness

  def full_name
    "#{first_name} #{last_name}"
  end

  def ensure_username_uniqueness
    if self.username.blank?
      username = self.first_name[0].downcase + self.last_name.downcase
      count = User.where(username: username).count

      if count == 0
        write_attribute(:username, username)
      else
        write_attribute(:username, "#{username}#{count}")
      end
    end
  end

end
