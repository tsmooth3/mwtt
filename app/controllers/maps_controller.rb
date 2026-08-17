class MapsController < ApplicationController
  def show
    @selected_season = selected_season
    @all_seasons = Season.order(year: :desc)
    @recap = @selected_season.recap?
    @include_previous = !@recap
    @pins = MapPin.for_season(@selected_season, include_previous: @include_previous, recap: @recap)
    @tree_entry = TreeEntry.new(entry_date: default_entry_date, family: current_family)
    @families = Family.all.order(:name)
  end

  private

  def selected_season
    if params[:season_id].present?
      Season.find_or_create_by_year(params[:season_id].to_i)
    else
      Season.current
    end
  end

  def default_entry_date
    Date.current
  end
end
