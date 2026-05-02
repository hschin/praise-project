require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "GET /health returns 200 when all checks pass" do
    get health_check_url
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "ok", body["status"]
    assert body["checks"]["database"]
    assert body["checks"]["queue"]
    assert body["checks"]["storage"]
    assert body["timestamp"].present?
  end

  test "GET /health does not require authentication" do
    get health_check_url
    assert_response :success
  end

  test "GET /health returns 503 when database is unavailable" do
    ActiveRecord::Base.stub(:connection, ->() { raise ActiveRecord::StatementInvalid, "simulated DB failure" }) do
      get health_check_url
    end
    assert_response :service_unavailable
    body = JSON.parse(response.body)
    assert_equal "degraded", body["status"]
    assert_equal false, body["checks"]["database"]
  end
end
