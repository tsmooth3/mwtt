require "test_helper"

class MapPinTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob = users(:two)
    @family = families(:one)
    @season = seasons(:season_2025)
    @previous = seasons(:season_2024)
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

  test "inventory pin reports collected and remaining" do
    log!(seen: 25, collected: 15)

    pin = MapPin.for_season(@season).find { |p| p[:id] == @location.id }

    assert_equal "inventory", pin[:state]
    assert_equal 15, pin[:collected]
    assert_equal 10, pin[:remaining]
    assert_equal "Pasadena east", pin[:name]
  end

  test "grab-and-go leaves remaining unknown" do
    log!(seen: 25, collected: 15, entry_date: Date.new(2026, 1, 3))
    log!(seen: nil, collected: 8, entry_date: Date.new(2026, 1, 8), user: @bob, family: families(:two))

    pin = MapPin.for_season(@season).find { |p| p[:id] == @location.id }

    assert_equal "unknown", pin[:state]
    assert_equal 23, pin[:collected]
    assert_nil pin[:remaining]
  end

  test "hidden locations are omitted" do
    log!(seen: 10, collected: 10)
    @location.hide!

    assert_empty MapPin.for_season(@season)
  end

  test "last-year hint is omitted unless requested" do
    log!(seen: 12, collected: 12, entry_date: Date.new(2025, 1, 10))

    assert_empty MapPin.for_season(@season)
    pins = MapPin.for_season(@season, include_previous: true)
    pin = pins.find { |p| p[:id] == @location.id }

    assert_equal "last_year", pin[:state]
    assert_equal 0, pin[:collected]
    assert_nil pin[:remaining]
    assert_equal 12, pin[:previous_collected]
  end

  test "recap does not advertise leftover as inventory" do
    log!(seen: 25, collected: 15)

    pin = MapPin.for_season(@season, recap: true).find { |p| p[:id] == @location.id }

    assert_equal "cleared", pin[:state]
    assert pin[:recap]
    assert_nil pin[:remaining]
  end

  test "upcoming season stays inventory not recap" do
    travel_to Date.new(2026, 8, 16) do
      log!(seen: 35, collected: 7, entry_date: Date.new(2026, 12, 5))
      season = Season.for_date(Date.new(2026, 12, 5))

      refute season.recap?
      pin = MapPin.for_season(season, recap: season.recap?).find { |p| p[:id] == @location.id }

      assert_equal "inventory", pin[:state]
      assert_equal 7, pin[:collected]
      assert_equal 28, pin[:remaining]
    end
  end

  test "cluster label sums collected and remaining" do
    pins = [
      { state: "inventory", collected: 15, remaining: 10 },
      { state: "cleared", collected: 8, remaining: 0 },
      { state: "last_year", collected: 0, remaining: nil, previous_collected: 20 }
    ]

    assert_equal "23 ↑ · 10 left", MapPin.cluster_label(pins)
  end

  test "cluster label marks unknown leftover" do
    pins = [
      { state: "inventory", collected: 15, remaining: 10 },
      { state: "unknown", collected: 8, remaining: nil }
    ]

    assert_equal "23 ↑ · 10+? left", MapPin.cluster_label(pins)
  end

  test "recap cluster is collected only" do
    pins = [
      { state: "cleared", collected: 15, remaining: nil, recap: true },
      { state: "empty", collected: 0, remaining: nil, recap: true }
    ]

    assert_equal "15", MapPin.cluster_label(pins, recap: true)
  end
end
