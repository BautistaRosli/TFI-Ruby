require "test_helper"

class DisksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get disks_index_url
    assert_response :success
  end

  test "should get show" do
    get disks_show_url
    assert_response :success
  end
end
