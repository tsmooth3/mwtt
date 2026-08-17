require "test_helper"

class TreeEntryTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @family = families(:one)
    @season = seasons(:season_2025)
  end

  def build_entry(attrs = {})
    TreeEntry.new({
      user: @user,
      family: @family,
      season: @season,
      entry_date: Date.new(2026, 1, 6),
      collected: 5
    }.merge(attrs))
  end

  test "collection without a pin is valid" do
    entry = build_entry(collected: 5, seen: nil, location: nil)

    assert entry.valid?
  end

  test "collection requires a family" do
    entry = build_entry(collected: 5, family: nil)

    refute entry.valid?
    assert_includes entry.errors[:family], "must be selected"
  end

  test "sighting requires a location" do
    entry = build_entry(collected: 0, seen: 10, location: nil, family: nil)

    refute entry.valid?
    assert entry.errors[:location].any?
  end

  test "sighting without a family is valid when pinned" do
    location = Location.create!(latitude: 39.0, longitude: -76.5, creator: @user)
    entry = build_entry(collected: 0, seen: 10, family: nil, location: location)

    assert entry.valid?
  end

  test "empty check is valid when pinned" do
    location = Location.create!(latitude: 39.0, longitude: -76.5, creator: @user)
    entry = build_entry(collected: 0, seen: 0, location: location, family: nil)

    assert entry.valid?
  end

  test "blank seen and zero collected with no pin is nothing" do
    entry = build_entry(collected: 0, seen: nil, location: nil, family: nil)

    refute entry.valid?
  end

  test "seen cannot be less than collected" do
    location = Location.create!(latitude: 39.0, longitude: -76.5, creator: @user)
    entry = build_entry(collected: 15, seen: 10, location: location)

    refute entry.valid?
    assert entry.errors[:seen].any?
  end

  test "seen zero cannot have collected trees" do
    location = Location.create!(latitude: 39.0, longitude: -76.5, creator: @user)
    entry = build_entry(collected: 3, seen: 0, location: location)

    refute entry.valid?
  end

  test "blank collected is treated as zero" do
    location = Location.create!(latitude: 39.0, longitude: -76.5, creator: @user)
    entry = build_entry(collected: nil, seen: 8, location: location, family: nil)

    assert entry.valid?
    assert_equal 0, entry.collected
  end

  test "off-window dates are assigned to the upcoming season" do
    entry = build_entry(entry_date: Date.new(2026, 8, 16), season: nil)

    assert entry.valid?
    assert_equal 2026, entry.season.year
  end

  test "assigns season from the winter window" do
    entry = build_entry(entry_date: Date.new(2027, 1, 4), season: nil)
    entry.valid?

    assert_equal 2026, entry.season.year
  end

  test "remaining is seen minus collected when seen is present" do
    location = Location.create!(latitude: 39.0, longitude: -76.5, creator: @user)
    entry = build_entry(collected: 15, seen: 25, location: location)

    assert_equal 10, entry.remaining
  end

  test "remaining is nil when seen is blank" do
    entry = build_entry(collected: 8, seen: nil)

    assert_nil entry.remaining
  end

  test "scouting includes leftover inventory from a partial collection" do
    location = Location.create!(latitude: 39.0, longitude: -76.5, creator: @user)
    leftover = TreeEntry.create!(user: @user, family: @family, location: location, entry_date: Date.new(2026, 12, 5), seen: 29, collected: 7)
    hauled = TreeEntry.create!(user: @user, family: @family, location: location, entry_date: Date.new(2026, 12, 6), collected: 4)
    empty = TreeEntry.create!(user: @user, family: nil, location: location, entry_date: Date.new(2026, 12, 7), seen: 0, collected: 0)

    scouting = TreeEntry.scouting

    assert_includes scouting, leftover
    assert_includes scouting, empty
    refute_includes scouting, hauled
  end
end
