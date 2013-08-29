class FavouritesController < ApplicationController
  before_action :signed_in_user

  def create
    @event = Event.find(params[:favourite][:event_id])
    current_user.favourite!(@event, params[:favourite][:day])
#    if current_user.diary_entries.find_by(event_id: @event.id, start_time.wday: params[:favourite][:day])
      # You don't want two entries for the same thing appearing simultaneously, so destroy the one-off diary entry.
#      current_user.diary_entries.find_by(event_id: @event.id, start_time.wday: params[:favourite][:day]).destroy
#    end
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end

  def destroy
    @fav = Favourite.find(params[:id])
    @event = @fav.event
    @fav.destroy
#    current_user.unfavourite!(@event.id, params[:day])
    redirect_to @event
  end
end
