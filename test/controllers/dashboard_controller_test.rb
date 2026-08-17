require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "counts collected trees toward the season total" do
    get dashboard_url, params: { season_id: 2025 }

    assert_response :success
    assert_match "8", response.body
  end

  test "shows the USA-age default when no override exists" do
    SeasonGoal.where(season: seasons(:season_2024)).delete_all

    get dashboard_url, params: { season_id: 2024 }

    assert_response :success
    assert_match "249", response.body
  end
end
