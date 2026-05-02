require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-extensions")
    options.add_argument("--window-size=1400,900")
  end

  include Devise::Test::IntegrationHelpers

  # Convenience: sign in and visit a path in one call
  def sign_in_and_visit(path, user: users(:one))
    sign_in user
    visit path
  end
end
