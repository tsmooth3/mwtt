require "test_helper"

class FamilyMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get family_memberships_create_url
    assert_response :success
  end

  test "should get destroy" do
    get family_memberships_destroy_url
    assert_response :success
  end
end
