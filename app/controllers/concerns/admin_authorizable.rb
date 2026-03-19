module AdminAuthorizable
  extend ActiveSupport::Concern

  private

  def require_admin
    unless current_user&.admin?
      Rails.logger.warn("[ADMIN AUDIT] Unauthorized access attempt by #{current_user&.email || 'unauthenticated'} to #{request.path}")
      redirect_to surveys_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
