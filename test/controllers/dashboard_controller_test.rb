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
end
