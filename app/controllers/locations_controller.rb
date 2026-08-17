class LocationsController < ApplicationController
  before_action :set_location

  def nearby
    locations = Location.nearby(params[:lat].to_f, params[:lng].to_f)
    render json: locations.map { |location|
      {
        id: location.id,
        name: location.display_name,
        latitude: location.latitude.to_f,
        longitude: location.longitude.to_f
      }
    }
  end

  def update
    unless @location.movable_by?(current_user)
      redirect_back fallback_location: map_path, alert: "This pin has other people's entries. Hide it and drop a new one."
      return
    end

    if @location.update(location_params)
      redirect_back fallback_location: map_path, notice: "Pin updated."
    else
      redirect_back fallback_location: map_path, alert: @location.errors.full_messages.to_sentence
    end
  end

  def destroy
    unless @location.deletable_by?(current_user)
      redirect_back fallback_location: map_path, alert: "This pin has other people's entries. Hide it instead."
      return
    end

    @location.destroy
    redirect_back fallback_location: map_path, notice: "Pin deleted."
  end

  def hide
    unless @location.hideable_by?(current_user)
      redirect_back fallback_location: map_path, alert: "Not authorized"
      return
    end

    @location.hide!
    redirect_back fallback_location: map_path, notice: "Pin hidden from every map."
  end

  def unhide
    unless @location.hideable_by?(current_user)
      redirect_back fallback_location: map_path, alert: "Not authorized"
      return
    end

    @location.unhide!
    redirect_back fallback_location: map_path, notice: "Pin is visible again."
  end

  private

  def set_location
    return if action_name == "nearby"

    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :latitude, :longitude)
  end
end
