class Event < ActiveRecord::Base
  include IceCube
  serialize :schedule, Hash

  belongs_to :venue
  has_many :tags, through: :relationships
  has_many :timings, dependent: :destroy
  accepts_nested_attributes_for :timings, :allow_destroy => true#, :reject_if => lambda { |a| a[:start_time].blank? | a[:end_time].blank? }
  has_many :favourites, dependent: :destroy
  has_many :relationships, dependent: :destroy

  default_scope -> { order('start_time ASC') }
  validates :venue_id, presence: true
  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 200 }
  acts_as_gmappable
  geocoded_by :gmaps4rails_address
  after_validation :geocode#, :if => :address_changed?

  def gmaps4rails_address
    "#{venue.gmaps4rails_address}"
  end

  def self.simple_search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end

  def schedule=(new_schedule)
    write_attribute(:schedule, new_schedule.to_hash)
  end

  def schedule
    Schedule.from_hash(read_attribute(:schedule))
  end

  def tagged?(property)
    relationships.find_by(tag_id: property.id)
  end

  def tagify!(property)
    relationships.create!(tag_id: property.id)
  end

  def untagify!(property)
    relationships.find_by(tag_id: property.id).destroy
  end

end
