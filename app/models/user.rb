class User < ActiveRecord::Base
  has_many :events, through: :favourites
  has_many :diary_entries
  has_many :logbook_entries
  has_many :messages, foreign_key: "receiver_id", dependent: :destroy
  has_many :sent_messages, class_name: "Message", 
                           foreign_key: "sender_id",
                           dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :articles

  has_many :mentorships, foreign_key: "mentor_id", dependent: :destroy
  has_many :mentees, through: :mentorships, source: :mentees
  has_many :reverse_mentorships, foreign_key: "mentee_id",
                                   class_name:  "Mentorship",
                                   dependent:   :destroy
  has_many :mentors, through: :reverse_mentorships, source: :mentor
  belongs_to :school
  validates :school_id, presence: true

  before_save { self.email = email.downcase }
  before_create :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, :on => :create,
                       :presence => true,
                       :confirmation => true,
                       :unless => :already_has_password?
  validates_presence_of :password_confirmation, :unless => lambda { |user| user.password.blank? }

  acts_as_gmappable
  after_validation :geocode

  geocoded_by :gmaps4rails_address

  ROLES = %w[admin teacher organiser mentor student]
  validates :role, presence: true, inclusion: {in: ROLES}

  def ip_address
    request.remote_ip
  end

  def self.search_by_school(name_search, school_search)
    puts "Search gives #{school_search} following #{school_search.to_i}"
    if school_search.to_i == 0
      all.where('UPPER(name) LIKE UPPER(?)', "%#{name_search}%")
    else
      all.where('UPPER(name) LIKE UPPER(?)', "%#{name_search}%").select { |u| u.school_id == school_search }
      #all.where('UPPER(name) LIKE UPPER(?) AND school_id LIKE ?', "%#{name_search}%", "%#{school_search}%")
    end
  end

  def self.search_by_name(name_search)
    if name_search
      all.where('UPPER(name) LIKE UPPER(?)', "%#{name_search}%")
    else
      all
    end
  end

  def gmaps4rails_address
    "#{home_address}, #{home_postcode}"
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def teaches?(thing)
    if thing.class.name=="User"
      (self.role == "teacher") && (self.school.id == thing.school.id)
    elsif thing.class.name=="Venue"
      (self.role == "teacher") && (self.school.venue_id == thing.id)
    else
      (self.role == "teacher") && (self.school.name == thing.venue.name)
    end
  end

  def mentoring?(other_user)
    mentorships.find_by(mentee_id: other_user.id)
  end

  def request_mentor!(other_user)
    mentorships.create!(mentee_id: other_user.id, confirmation_stage: 0)
  end

  def stop_mentoring!(other_user) # Thus phrased so as to clarify: the argument is the MENTEE.
    mentorships.find_by(mentee_id: other_user.id).destroy!
  end

  def is_favourite?(event, day)
    favourites.find_by(event_id: event.id, day: day)
  end

  def favourite!(event, day)
    favourites.create!(event_id: event.id, day: day)
  end

  def unfavourite!(eventid, day)
    favourites.find_by(event_id: eventid, day: day).destroy
  end
  
  def school_name
    School.find(self.school_id).name || "no school"
  end

  def has_school?
    self.school_id.to_i>1
  end

  def has_completed template
    entry = self.logbook_entries.find_by(template_id: template.id)
    if entry
      entry.is_complete
    else
      0
    end
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

    def already_has_password?
      !self.password.blank?
    end
end

