class FavouritesController < ApplicationController
  before_action :signed_in_user
  skip_before_filter :verify_authenticity_token  

  def create
    @favourite = current_user.favourites.create!(favourite_params)
    @event = Event.find(@favourite.event_id)
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

  private

    def favourite_params
      params.require(:favourite).permit(:event_id, :start_time)
    end
end
