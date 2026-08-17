require "test_helper"

class FamiliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "lists families" do
    get families_url

    assert_response :success
    assert_match families(:one).name, response.body
  end

  test "shows the new family form" do
    get new_family_url

    assert_response :success
  end

  test "creates a family" do
    assert_difference("Family.count", 1) do
      post families_url, params: { family: { name: "Birch Lane" } }
    end

    assert_redirected_to family_url(Family.order(:id).last)
  end

  test "shows a family" do
    get family_url(families(:one))

    assert_response :success
    assert_match families(:one).name, response.body
  end
end
