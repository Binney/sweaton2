class EventsController < ApplicationController

  before_action :organiser_account, only: [:create, :edit, :update, :destroy]
  before_action :correct_or_admin,  only: [:create, :edit, :update, :destroy]

  def index
    if params[:venue_id]==nil
      # Indexing from search so show all events
      @events = Event.paginate(page: params[:page])
    else # Indexing via venue so only show that venue's events
      @events = Venue.find(params[:venue_id]).events.paginate(page: params[:page])
      @number = Venue.find(params[:venue_id]).id
    end
  end

  def show
    @event = Event.find(params[:id])
    @tags = @event.tags.paginate(page: params[:page])
    @json = @event.venue.to_gmaps4rails
  end

  def new
    @event = Event.new
  end

  def create
    @event = Venue.find(event_params[:venue_id]).events.build(event_params)
    if @event.save
      flash[:success] = "Event created!"
      redirect_to @event.venue
    else
      render 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(event_params[:id])
    if @event.update_attributes(event_params)
      flash[:success] = "Event details updated"
      redirect_to @event
    else
      render 'edit'
    end
  end

  def destroy
    @event.destroy
    redirect_to Venue.find(@event.venue_id)
  end

  def tagged
    @title = "Tags"
    @event = Event.find(params[:id])
    @tags = @event.tags.paginate(page: params[:page])
    render 'show_tags'
  end

  private

    def event_params
      params.require(:event).permit(:name, :description, :start_time, :end_time, :venue_id, :tags)
    end

    def correct_or_admin
      current_venue = Venue.find(event_params[:venue_id])
      redirect_to(root_path) unless signed_in? && ((current_venue.user_id == current_user.id) || current_user.admin?)
    end

end
