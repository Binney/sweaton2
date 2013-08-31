class StaticPagesController < ApplicationController
  before_action :signed_in_user, only: :my_events
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
        str = event.tags[0] ? event.tags[0].name : "Other"
        #marker.picture({:picture => "/assets/tag_icons/#{str}.png", :width => 32, :height => 32})
        marker.picture({:picture => "/assets/tag_icons/l.png", :width => 32, :height => 32})
      end
      @house = current_user.to_gmaps4rails do |house, marker|
        marker.picture({:picture => "/assets/l.jpg", :width => 32, :height => 32})
      end
      @json = (JSON.parse(@evs) + JSON.parse(@house)).to_json
      @diary_entries = (current_user.diary_entries+current_user.favourites).shuffle
      @tags = Tag.all.shuffle
    else
      @venues = Venue.all :conditions => ["id != ?", 0] # Don't display venue(0) since it's a placeholder for events without a venue.
      @json = @venues.to_gmaps4rails do |venue, marker|
        marker.infowindow render_to_string(:partial => "/venues/infowindow", :locals => { :venue => venue})
        marker.title "#{venue.name}"
        #marker.picture({:picture => "/assets/tag_icons/Other.png", :width => 32, :height => 32})
        marker.picture({:picture => "/assets/tag_icons/l.png", :width => 32, :height => 32})
      end
      @todays_events = Timing.where(:day == Date.today.wday)[0..6]
      @tags = Tag.all.shuffle
    end
  end

  def my_events
    @title = "Your events"
    @favourites = current_user.events
    @favs = current_user.favourites
    @date = params[:month] ? Date.parse(params[:month]) : Date.today
    @calendar_entries = current_user.diary_entries.order('start_time ASC')
    arr = []
    @favs.each do |f|
      (((params[:month] ? Date.parse(params[:month]) : Date.today).change(day: 1)..(params[:month] ? Date.parse(params[:month]) : Date.today).advance(months: 1).change(day: 1)).select {|d| d.wday == f.day}).each do |date|
        @calendar_entries.push CalendarEntry.new(date, f.event_id)
      end
    end

    @upcoming_events = current_user.diary_entries#.where(:start_time > Date.now) # Needs to say "This Thursday" for entries and "Every Thursday" for favourites
  end

  def help
  end

  def about
  end

  def contact
  end

end
