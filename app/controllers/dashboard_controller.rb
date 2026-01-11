class DashboardController < ApplicationController
  def index
    @current_family = current_family
    
    # Get selected season from params, default to current year
    selected_year = params[:season_id]&.to_i || Date.current.year
    @selected_season = Season.find_or_create_by_year(selected_year)
    @all_seasons = Season.order(year: :desc)
    
    if @current_family
      @family_total = TreeEntry.for_family(@current_family)
                                .for_season(@selected_season)
                                .sum(:tree_count)
      
      @family_entries = TreeEntry.for_family(@current_family)
                                  .for_season(@selected_season)
                                  .recent
                                  .limit(10)
    end
    
    @overall_total = TreeEntry.for_season(@selected_season).sum(:tree_count)
    @recent_entries = TreeEntry.for_season(@selected_season).recent.limit(10)
    
    # Season goal is for the whole season (not per family)
    @season_goal = SeasonGoal.find_by(season: @selected_season)
    @overall_progress = @season_goal && @season_goal.goal_count > 0 ? (@overall_total.to_f / @season_goal.goal_count * 100) : 0
  end
end
