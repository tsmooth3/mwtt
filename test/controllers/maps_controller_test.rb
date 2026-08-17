require "test_helper"

class MapsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "shows the map for the selected season" do
    location = Location.create!(latitude: 39.162, longitude: -76.624, name: "Pasadena east", creator: users(:one))
    TreeEntry.create!(
      user: users(:one),
      family: families(:one),
      location: location,
      entry_date: Date.new(2026, 1, 6),
      seen: 25,
      collected: 15
    )

    get map_url, params: { season_id: 2025 }

    assert_response :success
    assert_match "Pasadena east", response.body
    assert_match "inventory", response.body
  end
end
