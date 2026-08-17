class SeasonGoalsController < ApplicationController
  before_action :ensure_family_admin
  before_action :set_season, only: [ :edit, :update ]

  def edit
    @season_goal = @season.season_goal || @season.build_season_goal(goal_count: @season.default_goal_count)
  end

  def update
    @season_goal = SeasonGoal.find_or_initialize_by(season: @season)

    if @season_goal.update(season_goal_params)
      redirect_to dashboard_path(season_id: @season.year), notice: "Season goal updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_season
    @season = Season.find_or_create_by_year(params[:id])
  end

  def ensure_family_admin
    unless current_user.any_family_admin?
      redirect_to dashboard_path, alert: "Only family admins can set goals."
    end
  end

  def season_goal_params
    params.require(:season_goal).permit(:goal_count)
  end
end
