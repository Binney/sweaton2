module VenuesHelper

  def venue_image_for(venue)
    image_tag "l.jpg", alt: venue.name, size: "60x60"
  end

end
