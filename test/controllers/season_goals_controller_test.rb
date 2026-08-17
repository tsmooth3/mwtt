require "test_helper"

class SeasonGoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    family_memberships(:one).update!(is_admin: true)
    sign_in users(:one)
  end

  test "creates a season goal" do
    SeasonGoal.where(season: seasons(:season_2024)).delete_all

    post season_goals_url, params: { season_id: 2024, goal_count: 180 }

    assert_redirected_to dashboard_path(season_id: 2024)
    assert_equal 180, SeasonGoal.find_by!(season: seasons(:season_2024)).goal_count
  end

  test "updates a season goal" do
    patch season_goal_url(season_goals(:season_2025)), params: {
      season_goal: { goal_count: 300 }
    }

    assert_redirected_to dashboard_path(season_id: 2025)
    assert_equal 300, season_goals(:season_2025).reload.goal_count
  end
end
