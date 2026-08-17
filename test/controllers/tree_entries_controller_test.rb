require "test_helper"

class TreeEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "creates a collection without a pin" do
    assert_difference("TreeEntry.count", 1) do
      post tree_entries_url, params: {
        tree_entry: {
          family_id: families(:one).id,
          entry_date: "2026-01-10",
          collected: 7
        }
      }
    end

    entry = TreeEntry.order(:id).last
    assert_equal 7, entry.collected
    assert_nil entry.location
    assert_equal 2025, entry.season.year
    assert_redirected_to tree_entries_path
  end

  test "accepts an off-window date for the upcoming season" do
    assert_difference("TreeEntry.count", 1) do
      post tree_entries_url, params: {
        tree_entry: {
          family_id: families(:one).id,
          entry_date: "2026-08-16",
          collected: 3
        }
      }
    end

    assert_equal 2026, TreeEntry.order(:id).last.season.year
  end

  test "index defaults to the current season" do
    get tree_entries_url

    assert_response :success
    assert_select "select[name=season_id]"
  end

  test "creates a sighting at a new pin without a family" do
    assert_difference([ "TreeEntry.count", "Location.count" ], 1) do
      post tree_entries_url, params: {
        tree_entry: {
          entry_date: "2026-01-10",
          seen: 12,
          collected: 0,
          latitude: 39.162,
          longitude: -76.624,
          location_name: "Pasadena east"
        }
      }
    end

    entry = TreeEntry.order(:id).last
    assert_equal 12, entry.seen
    assert_equal 0, entry.collected
    assert_nil entry.family
    assert_equal "Pasadena east", entry.location.name
  end

  test "attaches a collection to an existing pin" do
    location = Location.create!(latitude: 39.162, longitude: -76.624, creator: @user)

    post tree_entries_url, params: {
      tree_entry: {
        family_id: families(:one).id,
        entry_date: "2026-01-12",
        collected: 4,
        location_id: location.id
      }
    }

    assert_equal location, TreeEntry.order(:id).last.location
  end
end
