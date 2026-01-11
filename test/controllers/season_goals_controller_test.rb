require "test_helper"

class SeasonGoalsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get season_goals_create_url
    assert_response :success
  end

  test "should get update" do
    get season_goals_update_url
    assert_response :success
  end
end
