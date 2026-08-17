require "test_helper"

class LocationTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob = users(:two)
    @family = families(:one)
    @season = seasons(:season_2025)
    @location = Location.create!(latitude: 39.162, longitude: -76.624, name: "Pasadena east", creator: @alice)
  end

  def log!(attrs)
    TreeEntry.create!({
      user: @alice,
      family: @family,
      location: @location,
      entry_date: Date.new(2026, 1, 6)
    }.merge(attrs))
  end

  test "inventory remaining comes from the latest seen report" do
    log!(seen: 25, collected: 15, entry_date: Date.new(2026, 1, 3))
    log!(seen: 8, collected: 8, entry_date: Date.new(2026, 1, 8), user: @bob, family: families(:two))

    assert_equal 0, @location.remaining_for(@season)
    assert_equal :cleared, @location.operational_state(@season)
  end

  test "grab-and-go without seen leaves leftover unknown" do
    log!(seen: 25, collected: 15, entry_date: Date.new(2026, 1, 3))
    log!(seen: nil, collected: 8, entry_date: Date.new(2026, 1, 8), user: @bob, family: families(:two))

    assert_nil @location.remaining_for(@season)
    assert_equal :unknown, @location.operational_state(@season)
    assert_equal 23, @location.collected_for(@season)
  end

  test "positive remaining is inventory even if trees were also collected" do
    log!(seen: 25, collected: 15)

    assert_equal 10, @location.remaining_for(@season)
    assert_equal :inventory, @location.operational_state(@season)
  end

  test "empty check is empty" do
    log!(seen: 0, collected: 0, family: nil)

    assert_equal 0, @location.remaining_for(@season)
    assert_equal :empty, @location.operational_state(@season)
  end

  test "cannot move a location other people have used" do
    log!(seen: 10, collected: 10, user: @bob, family: families(:two))

    refute @location.movable_by?(@alice)
    refute @location.deletable_by?(@alice)
    assert @location.hideable_by?(@alice)
  end

  test "author can move a location only they have used" do
    log!(seen: 10, collected: 10)

    assert @location.movable_by?(@alice)
    assert @location.deletable_by?(@alice)
  end

  test "nearby offers existing visible pins" do
    far = Location.create!(latitude: 38.0, longitude: -77.0, creator: @alice)

    results = Location.nearby(39.162, -76.624)

    assert_includes results, @location
    refute_includes results, far
  end
end
