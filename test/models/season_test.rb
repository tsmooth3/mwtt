require "test_helper"

class SeasonTest < ActiveSupport::TestCase
  test "for_date assigns January to the previous Christmas" do
    season = Season.for_date(Date.new(2027, 1, 4))

    assert_equal 2026, season.year
  end

  test "for_date assigns December 26 to that Christmas" do
    season = Season.for_date(Date.new(2026, 12, 26))

    assert_equal 2026, season.year
  end

  test "for_date assigns December 1 slop to the coming Christmas" do
    season = Season.for_date(Date.new(2026, 12, 1))

    assert_equal 2026, season.year
  end

  test "for_date assigns February 15 slop to the previous Christmas" do
    season = Season.for_date(Date.new(2027, 2, 15))

    assert_equal 2026, season.year
  end

  test "in_window? is false in July" do
    refute Season.in_window?(Date.new(2026, 7, 4))
  end

  test "in_window? is true on the slop edges" do
    assert Season.in_window?(Date.new(2026, 12, 1))
    assert Season.in_window?(Date.new(2027, 2, 15))
  end

  test "off-window dates belong to the upcoming Christmas" do
    assert_equal 2026, Season.year_for(Date.new(2026, 7, 4))
    assert_equal 2026, Season.year_for(Date.new(2026, 8, 16))
    assert_equal 2027, Season.year_for(Date.new(2027, 2, 20))
  end

  test "current is the upcoming hunt after the window closes" do
    travel_to Date.new(2026, 8, 16) do
      assert_equal 2026, Season.current.year
      assert Season.current.live?
      refute seasons(:season_2025).live?
    end
  end

  test "current is the live winter during the hunt" do
    travel_to Date.new(2027, 1, 10) do
      assert_equal 2026, Season.current.year
      assert Season.current.live?
    end
  end
end
