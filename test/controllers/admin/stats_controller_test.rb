require "test_helper"

class Admin::StatsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @prev_user = ENV["ADMIN_DASHBOARD_USER"]
    @prev_pass = ENV["ADMIN_DASHBOARD_PASSWORD"]
    ENV["ADMIN_DASHBOARD_USER"] = "admin"
    ENV["ADMIN_DASHBOARD_PASSWORD"] = "secret"
  end

  def teardown
    ENV["ADMIN_DASHBOARD_USER"] = @prev_user
    ENV["ADMIN_DASHBOARD_PASSWORD"] = @prev_pass
  end

  test "requires basic auth" do
    get admin_stats_path
    assert_response :unauthorized
  end

  test "renders stats with valid credentials" do
    get admin_stats_path, headers: auth_headers("admin", "secret")
    assert_response :success
    assert_includes @response.body, "Admin Dashboard"
    assert_includes @response.body, "Events"
    assert_includes @response.body, "Queue"
  end

  private

  def auth_headers(user, password)
    {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
    }
  end
end
