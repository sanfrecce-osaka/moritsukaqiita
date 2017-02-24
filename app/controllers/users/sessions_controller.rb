class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  def new
    super
  end

  def create
    conditions = {login_key: params['user']['login_key']}
    user = User.find_first_by_auth_conditions(conditions)
    if user && !user.encrypted_password.present?
      self.resource = User.new(login_key: params['user']['login_key'])
      flash.now.alert = 'パスワードが設定されていないユーザです。TwitterかGitHubでログインしてください。'
      render action: 'new' and return
    end
    super
  end

  def destroy
    super
  end

  def after_sign_in_path_for(resource)
    if session[:user_return_to]
      super
    else
      path = session[:previous_url] || authenticated_root_path
      session.delete(:previous_url)
      path
    end
  end

  def after_sign_out_path_for(resource)
    if request.referer !~ Regexp.new("\\A.*/users/.*\\z") &&
      !request.xhr?
      request.referer
    else
      unauthenticated_root_url
    end
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login_key, :user_name])
  end
end
