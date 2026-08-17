require "test_helper"

class SeasonGoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    family_memberships(:one).update!(is_admin: true)
    sign_in users(:one)
  end

  test "edit prefills the USA-age default when no override exists" do
    SeasonGoal.where(season: seasons(:season_2024)).delete_all

    get edit_season_goal_url(2024)

    assert_response :success
    assert_select "input[name='season_goal[goal_count]'][value='249']"
  end

  test "update creates an override for a season without one" do
    SeasonGoal.where(season: seasons(:season_2024)).delete_all

    patch season_goal_url(2024), params: { season_goal: { goal_count: 180 } }

    assert_redirected_to dashboard_path(season_id: 2024)
    assert_equal 180, seasons(:season_2024).reload.goal_count
  end

  test "update changes an existing override" do
    patch season_goal_url(2025), params: { season_goal: { goal_count: 300 } }

    assert_redirected_to dashboard_path(season_id: 2025)
    assert_equal 300, seasons(:season_2025).reload.goal_count
  end
end
