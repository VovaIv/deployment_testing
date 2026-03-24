module AdminAuthorizable
  extend ActiveSupport::Concern

  private

  def require_admin
    authenticate_user!
    return if current_user.admin?

    safe_path  = request.path.to_s.gsub(/[^\w\-\/]/, '_')
    safe_email = sanitize_log(current_user.email)
    Rails.logger.warn("[ADMIN AUDIT] Unauthorized access attempt by #{safe_email} to #{safe_path}")
    redirect_to surveys_path, alert: 'You are not authorized to perform this action.'
  end

  def sanitize_log(value)
    value.to_s
         .gsub(/[[:cntrl:]]/, '_')
         .gsub(/[\u202A-\u202E\u2066-\u2069]/, '_')
  end
end
