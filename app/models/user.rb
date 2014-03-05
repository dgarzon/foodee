class User < ActiveRecord::Base
  # added for recommendations
  has_many :recommendation, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_one :indentity, :dependent => :destroy

  has_many :addresses, :dependent => :destroy

  validates_presence_of :email, :first_name, :last_name

  def full_name
    "#{first_name} #{last_name}"
  end

end
