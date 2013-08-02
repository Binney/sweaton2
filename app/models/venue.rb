class Venue < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :favourites, dependent: :destroy
  default_scope -> { order('name ASC') }
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 200 }
  acts_as_gmappable
  
  def gmaps4rails_address
    "#{street_address}, #{postcode}, UK"
  end

end
