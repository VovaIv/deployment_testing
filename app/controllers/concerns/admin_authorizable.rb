module AdminAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to surveys_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
