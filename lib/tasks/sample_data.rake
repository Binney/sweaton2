namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "The Flying Spaghetti Monster",
                         email: "fsm@railstutorial.org",
                         password: "foobar",
                         password_confirmation: "foobar",
                         admin: true)
    teacher = User.create!(name: "Dr Jekyll The Maths Teacher",
                         email: "teacher@railstutorial.org",
                         password: "foobar",
                         password_confirmation: "foobar",
                         mentor: true)
    organiser = User.create!(name: "Mr Hyde The Sports Coach",
                         email: "organiser@railstutorial.org",
                         password: "foobar",
                         password_confirmation: "foobar",
                         organiser: true)

    other_venues = Venue.create!(name: "Other Venue",
				 description: "Other venue not listed above", user_id: 0,
                                 postcode: 'W6 7BS', street_address: 'Brook Green', gmaps: true )
    20.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      user = User.create!(name: name, email: email, password: password,
                   password_confirmation: password)
      Venue.create!(name: Faker::Company.name,
		    description: "We specialise in Sport!", user_id: 21-n,
                    postcode: '', street_address: n.to_s+' Hammersmith Road', gmaps: true)
    end
    venues = Venue.all(limit: 6)
    25.times do
      content = Faker::Lorem.sentence(5)
      start_time = 3.days.from_now
      venues.each { |venue| venue.events.create!(name: "Society Meeting", description: content,
						 start_time: start_time, end_time: start_time.advance(hours: 1)) }
    end
 
    Tag.create!(name: 'sport')
    Tag.create!(name: 'martial arts')
    Tag.create!(name: 'youth club')
    Tag.create!(name: 'football')
    Tag.create!(name: 'rugby')
    Tag.create!(name: 'basketball')
    Tag.create!(name: 'cricket')
    Tag.create!(name: 'dance')
    Tag.create!(name: 'aerobics')
    Tag.create!(name: 'band')
    Tag.create!(name: 'orchestra')
    Tag.create!(name: 'choir')
    Tag.create!(name: 'cooking')
    # ...And so on...

  end
end
