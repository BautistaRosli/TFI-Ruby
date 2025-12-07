require "test_helper"

class Disk::UsedControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get disk_used_index_url
    assert_response :success
  end

  test "should get show" do
    get disk_used_show_url
    assert_response :success
  end
end
