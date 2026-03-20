module AdminAuthorizable
  extend ActiveSupport::Concern

  private

  def require_admin
    unless current_user&.admin?
      safe_path = request.path.gsub(/[\r\n\t]/, '_')
      Rails.logger.warn("[ADMIN AUDIT] Unauthorized access attempt by #{current_user&.email || 'unauthenticated'} to #{safe_path}")
      redirect_to surveys_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
