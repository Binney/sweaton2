class User < ActiveRecord::Base
  has_many :events, through: :favourites
  has_many :diary_entries # oh them lovely plurals
  has_many :messages, foreign_key: "receiver_id", dependent: :destroy
  has_many :messages, foreign_key: "sender_id", dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :reviews, dependent: :destroy

  before_save { self.email = email.downcase }
  before_create :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :minimum => 6 },
                       :unless => :already_has_password?
  validates_presence_of :password_confirmation, :unless => lambda { |user| user.password.blank? }



  acts_as_gmappable
  after_validation :geocode

  if :home_address?
    geocoded_by :gmaps4rails_address
  else
    geocoded_by :ip_address
  end

  def ip_address
    request.remote_ip
  end

  def gmaps4rails_address
    "#{home_address}, #{home_postcode}"
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
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

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

    def already_has_password?
      !self.password.blank?
    end
end

