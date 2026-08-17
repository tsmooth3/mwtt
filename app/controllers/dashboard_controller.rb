class DashboardController < ApplicationController
  def index
    @current_family = current_family

    selected_year = params[:season_id]&.to_i
    @selected_season = selected_year ? Season.find_or_create_by_year(selected_year) : Season.current
    @all_seasons = Season.order(year: :desc)
    @recap = @selected_season.recap?

    if @current_family
      @family_total = TreeEntry.for_family(@current_family)
                                .for_season(@selected_season)
                                .sum(:collected)

      @family_entries = TreeEntry.for_family(@current_family)
                                  .for_season(@selected_season)
                                  .recent
                                  .limit(10)
    end

    @overall_total = TreeEntry.for_season(@selected_season).sum(:collected)
    @recent_entries = TreeEntry.for_season(@selected_season).collections.recent.limit(10)

    @season_goal = SeasonGoal.find_by(season: @selected_season)
    @overall_progress = @season_goal && @season_goal.goal_count > 0 ? (@overall_total.to_f / @season_goal.goal_count * 100) : 0

    @map_pins = MapPin.for_season(@selected_season, recap: @recap)
  end
end
