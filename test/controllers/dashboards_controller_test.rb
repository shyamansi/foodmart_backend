require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get summary" do
    get dashboards_summary_url
    assert_response :success
  end
end
