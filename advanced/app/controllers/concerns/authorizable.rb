module Authorizable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :require_admin
  end

  private

  def require_admin
    return if current_user.try(:admin?)
    redirect_to root_url, alert: t('authorization.unauthorized_access')
  end
end
