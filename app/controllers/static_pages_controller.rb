class StaticPagesController < ApplicationController
  def home
    # Okay. Needs to process whether you're logged in and if so, how.
    # If you're not logged in, it just shows all venues.

    # If logged in with a student account, it plots all your favourites
    # in a different colour to other venues, and centres around your
    # saved Home address.
    @search = Event.search(params[:q])

    if signed_in?
      @events = current_user.events

      # Consolidate all your map markers into one json and plot:
      @evs = @events.to_gmaps4rails do |event, marker|
        marker.infowindow render_to_string(:partial => "/events/infowindow", :locals => { :event => event })
        marker.title "#{event.name}"
        marker.picture({:picture => "/assets/tag_icons/drinking society.png", :width => 32, :height => 32})
      end
      @house = current_user.to_gmaps4rails do |house, marker|
        marker.picture({:picture => "/assets/tag_icons/martial arts.png", :width => 32, :height => 32})
      end
      @json = (JSON.parse(@evs) + JSON.parse(@house)).to_json

    else
      @venues = Venue.all :conditions => ["id != ?", 0] # Don't display venue(0) since it's a placeholder for events without a venue.
      @json = @venues.to_gmaps4rails do |venue, marker|
        marker.infowindow render_to_string(:partial => "/venues/infowindow", :locals => { :venue => venue})
        marker.title "#{venue.name}"
        marker.picture({:picture => "/assets/tag_icons/assassins.png", :width => 32, :height => 32})
      end
    end
  end

  def my_events
    @title = "Your events"
    @events = current_user.events
    @date = params[:month] ? Date.parse(params[:month]) : Date.today
    # Here: loop through days of this month and create array of times for each Favourite which falls on that day. Then concatenate it to the @entries array. Then table_builder can do its utmost to plot multiple days.
    @entries = current_user.diary_entries.order('start_time ASC')
#    @upcoming_events = current_user.diary_entries.where(start_date > Datetime.now) # Needs to say "This Thursday" for entries and "Every Thursday" for favourites
  end

  def help
  end

  def about
  end

  def contact
  end

end
