class EventsController < ApplicationController

  before_action :organiser_account, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_or_admin,  only: [:edit, :update, :destroy]
  before_action :correct_school, only: :show

  def index
    if params[:venue_id] # Indexing via venue so only show that venue's events
      @events = Venue.find(params[:venue_id]).events.paginate(page: params[:page])
      @number = params[:venue_id]
    else
      if params[:q]
        # Indexing from search
        @search = Event.search(params[:q])
        @search.sorts = 'distance_to(#{params[:q][:gender_not_cont]) asc' unless params[:q][:gender_not_cont].nil?
        @events = @search.result#.paginate(:page => params[:page])
      else # Just indexing normally
        @search = Event.search(params[:q])
        @events = @search.result
      end
      @json = @events.to_gmaps4rails do |event, marker|
        marker.infowindow render_to_string(:partial => "/events/infowindow", :locals => { :event => event })
        marker.title "#{event.name}"
        image = event.tags.count==0 ? "Other" : event.tags[0].name
        marker.picture({:picture => "/assets/tag_icons/small/#{image}.png", :width => 35, :height => 48})
      end
    end
  end

  def show
    @event = Event.find(params[:id])
    @timings = @event.timings
    @tags = @event.tags.paginate(page: params[:page])
    @json = @event.venue.to_gmaps4rails do |venue, marker|
      marker.infowindow render_to_string(:partial => "/events/infowindow", :locals => { :event => @event })
      marker.title "#{venue.name}"
      image = @event.tags.count==0 ? "Other" : @event.tags[0].name
      marker.picture({:picture => "/assets/tag_icons/small/#{image}.png", :width => 32, :height => 32})
    end
  end

  def new
    @event = Event.new
    @venues = Venue.all
  end

  def create
    @event = Venue.find(event_params[:venue_id]).events.build(event_params)
    if @event.save
      flash[:success] = "Event created!"
      redirect_to @event
    else
      flash[:error] = "Couldn't create event"
      render 'static_pages/home'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    params[:event][:tag_ids] ||= []
    @event = Event.find(params[:id])
    @event.attributes = {'tag_ids' => []}.merge(params[:event] || {})
    if @event.update_attributes(event_params)
      flash[:success] = "Event details updated"
      redirect_to @event
    else
      render 'edit'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @venue = Venue.find(@event.venue_id)
    @event.destroy
    redirect_to @venue
  end

  def tagged
    @title = "Tags"
    @event = Event.find(params[:id])
    @tags = @event.tags.paginate(page: params[:page])
    render 'show_tags'
  end

  private

    def event_params
      params.require(:event).permit!#(:name, :description, :day_info, :venue_id, :contact, :website, :gender, tag_ids: [:id], timings_attributes: [:id, :day, :start_time, :end_time, :_destroy])
    end

    def correct_or_admin
      current_venue = Event.find(params[:id]).venue
      redirect_to(root_path) unless signed_in? && ((current_venue.user_id == current_user.id) || current_user.admin?)
    end

    def correct_school
      current_venue = Event.find(params[:id]).venue
      if current_venue.is_school
        redirect_to(root_path) unless signed_in? && (current_venue.name.eql?(current_user.school) || current_user.admin?)
      end
    end

end
