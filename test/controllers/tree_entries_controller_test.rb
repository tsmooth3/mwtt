require "test_helper"

class TreeEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tree_entries_index_url
    assert_response :success
  end

  test "should get new" do
    get tree_entries_new_url
    assert_response :success
  end

  test "should get create" do
    get tree_entries_create_url
    assert_response :success
  end

  test "should get edit" do
    get tree_entries_edit_url
    assert_response :success
  end

  test "should get update" do
    get tree_entries_update_url
    assert_response :success
  end

  test "should get destroy" do
    get tree_entries_destroy_url
    assert_response :success
  end

  test "should get show" do
    get tree_entries_show_url
    assert_response :success
  end
end
