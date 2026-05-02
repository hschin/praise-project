class HealthController < ApplicationController
  # Health endpoint is public — no auth required, no browser check
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_authenticity_token, raise: false

  def show
    checks = {
      database: database_ok?,
      queue:    queue_ok?,
      storage:  storage_ok?
    }

    all_ok = checks.values.all?
    status = all_ok ? :ok : :service_unavailable

    render json: {
      status:    all_ok ? "ok" : "degraded",
      checks:    checks,
      timestamp: Time.current.iso8601,
      version:   ENV.fetch("APP_VERSION", "unknown")
    }, status: status
  end

  private

  def database_ok?
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue => e
    Rails.logger.error("[Health] database check failed: #{e.message}")
    false
  end

  def queue_ok?
    # Solid Queue stores jobs in the database — if DB is up, this is a fast count
    SolidQueue::Job.count >= 0
    true
  rescue => e
    Rails.logger.error("[Health] queue check failed: #{e.message}")
    false
  end

  def storage_ok?
    # Verifies ActiveStorage metadata table is reachable
    ActiveStorage::Blob.count >= 0
    true
  rescue => e
    Rails.logger.error("[Health] storage check failed: #{e.message}")
    false
  end
end
