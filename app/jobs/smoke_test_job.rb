class SmokeTestJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[SmokeTestJob] Worker is alive at #{Time.current}"
  end
end
