class SeasonGoalsController < ApplicationController
  before_action :ensure_family_admin

  def create
    @season = Season.find_or_create_by_year(params[:season_id] || Date.current.year)
    
    @season_goal = SeasonGoal.find_or_initialize_by(season: @season)
    @season_goal.goal_count = params[:goal_count].to_i
    
    if @season_goal.save
      redirect_to dashboard_path(season_id: @season.year), notice: 'Season goal set successfully!'
    else
      redirect_to dashboard_path(season_id: @season.year), alert: @season_goal.errors.full_messages.join(', ')
    end
  rescue => e
    redirect_to dashboard_path(season_id: @season.year), alert: "Error setting goal: #{e.message}"
  end

  def edit
    @season_goal = SeasonGoal.find(params[:id])
  end

  def update
    @season_goal = SeasonGoal.find(params[:id])
    
    if @season_goal.update(season_goal_params)
      redirect_to dashboard_path(season_id: @season_goal.season.year), notice: 'Season goal updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ensure_family_admin
    unless current_user.any_family_admin?
      redirect_to dashboard_path, alert: 'Only family admins can set goals.'
    end
  end

  def season_goal_params
    params.require(:season_goal).permit(:goal_count)
  end
end
