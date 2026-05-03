class Users::PasswordsController < Devise::PasswordsController
  # Override create to handle SMTP failures gracefully instead of raising 500.
  # During SES sandbox mode, sending to unverified addresses raises Net::SMTPFatalError.
  # In production, this could also catch transient SMTP timeouts.
  def create
    super
  rescue Net::SMTPFatalError, Net::SMTPServerBusy, Net::ReadTimeout, Errno::ECONNREFUSED => e
    Rails.logger.error("[PasswordsController] SMTP error sending reset email: #{e.message}")
    flash[:alert] = "We couldn't send the reset email right now. Please try again shortly."
    redirect_to new_user_password_path
  end
end
