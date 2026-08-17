require "test_helper"

class FamilyMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "joins a family when the user has none" do
    sign_in users(:joiner)

    assert_difference("FamilyMembership.count", 1) do
      post family_family_memberships_url(families(:two))
    end

    assert_redirected_to family_url(families(:two))
    assert users(:joiner).families.include?(families(:two))
  end

  test "leaves a family when the user is not an admin" do
    sign_in users(:one)

    assert_difference("FamilyMembership.count", -1) do
      delete family_family_membership_url(families(:one), family_memberships(:one))
    end

    assert_redirected_to families_url
  end
end
