class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :ensure_user_has_family, unless: :skip_family_check?
  
  # Override Devise's after_sign_in_path_for to redirect to families if needed
  def after_sign_in_path_for(resource)
    if resource.families.any?
      super
    else
      families_path
    end
  end

  protected

  def current_family
    @current_family ||= current_user&.current_family
  end
  helper_method :current_family

  def user_has_family?
    current_user&.families&.any?
  end
  helper_method :user_has_family?

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def ensure_user_has_family
    # Only check if user is actually signed in
    return unless user_signed_in?
    return if user_has_family?
    
    redirect_to families_path, alert: "Please join or create a family to continue."
  end

  def skip_family_check?
    # Skip check on families pages, sign out, and health check
    # Devise controllers are namespaced, so check the full path
    return true if controller_path.start_with?('devise/')
    return true if controller_name == 'families'
    return true if controller_name == 'family_memberships'
    return true if controller_path == 'rails/health' && action_name == 'show'
    
    false
  end

  def record_not_found
    redirect_to root_path, alert: "Record not found."
  end
end
