require "test_helper"

class Admin::QueuesControllerTest < ActionDispatch::IntegrationTest
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
    get admin_queue_path
    assert_response :unauthorized
  end

  test "renders queue dashboard with valid credentials" do
    get admin_queue_path, headers: auth_headers("admin", "secret")
    assert_response :success
    assert_includes @response.body, "Queue Dashboard"
    assert_includes @response.body, "Failed (latest 50)"
  end

  test "discards failed jobs" do
    job = SolidQueue::Job.create!(queue_name: "default", class_name: "TestJob")
    SolidQueue::FailedExecution.create!(job: job, error: "boom")

    assert_difference -> { SolidQueue::FailedExecution.count }, -1 do
      post discard_failed_admin_queue_path, headers: auth_headers("admin", "secret")
    end

    assert_redirected_to admin_queue_path
  end

  test "retries failed jobs" do
    job = SolidQueue::Job.create!(queue_name: "default", class_name: "TestJob")
    SolidQueue::FailedExecution.create!(job: job, error: "boom")

    assert_difference -> { SolidQueue::FailedExecution.count }, -1 do
      post retry_failed_admin_queue_path, headers: auth_headers("admin", "secret")
    end

    assert_redirected_to admin_queue_path
  end

  test "shows failed job details" do
    job = SolidQueue::Job.create!(queue_name: "default", class_name: "TestJob")
    failure = SolidQueue::FailedExecution.create!(job: job, error: { message: "boom", backtrace: [ "line 1" ] })

    get failed_admin_queue_path(failure), headers: auth_headers("admin", "secret")
    assert_response :success
    assert_includes @response.body, "Failed Job"
    assert_includes @response.body, "boom"
    assert_includes @response.body, "line 1"
  end

  private

  def auth_headers(user, password)
    {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
    }
  end
end
