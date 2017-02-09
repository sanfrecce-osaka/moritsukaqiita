class Users::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]

# GET /resource/sign_in
  def new
    super
  end

# POST /resource/sign_in
  def create
    super
  end

# DELETE /resource/sign_out
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

# protected

# If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
#   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
