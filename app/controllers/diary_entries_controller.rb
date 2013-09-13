class DiaryEntriesController < ApplicationController
  before_action :signed_in_user

  def new
    @diary_entry = current_user.diary_entries.build
  end

  def create
    @diary_entry = current_user.diary_entries.create!(diary_entry_params)
    if @diary_entry.event_id
      @event = Event.find(@diary_entry.event_id)
      respond_to do |format|
        format.html { redirect_to @event }
        format.js
      end
    else
      redirect_to my_events_path
    end
  end

  def destroy
    @diary_entry = current_user.diary_entries.find_by(id: params[:id])
    if @diary_entry.event_id == 0
      it = favourites_user_path(current_user)
    else
      it = event_path(@diary_entry.event_id)
    end
    @diary_entry.destroy
    redirect_to it
    #respond_to do |format|
    #  format.html { redirect_to it }
    #  format.js
    #end
  end

  private

    def diary_entry_params
      params.require(:diary_entry).permit(:event_id, :start_time, :name)
    end
end
