require "test_helper"

class Disk::NewControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get disk_new_index_url
    assert_response :success
  end

  test "should get show" do
    get disk_new_show_url
    assert_response :success
  end
end
