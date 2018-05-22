class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def after_sign_out_path_for(resource_or_scope)
    admin_login_path
  end

  def after_sign_in_path_for(resource_or_scope)
    admin_orders_path
  end
end
