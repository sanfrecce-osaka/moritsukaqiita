class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  def new
    super
  end

  def create
    super
  end

  def destroy
    super
  end

  def after_sign_in_path_for(resource)
    if session[:previous_url] == authenticated_root_path
      super
    else
      path = session[:previous_url] || authenticated_root_path
      session.delete(:previous_url)
      path
    end
  end

  def after_sign_out_path_for(resource)
    request.referer
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login_key, :user_name])
  end
end
