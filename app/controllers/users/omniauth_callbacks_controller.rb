class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def callback_for_all_providers
    profile = User::OmniauthService.new(request.env['omniauth.auth']).find_or_build_for_omniauth

    if profile.persisted?
      set_flash_message(:notice, :success) if is_navigational_format?
      sign_in_and_redirect profile.user, event: :authentication
    else
      if user_signed_in?
        current_user.social_profiles << profile
        redirect_to session[:previous_url]
      else
        @user = User.new(user_name: profile.user_name,
                         email:     profile.email)
        session['devise.oauth_data'] = profile
        render template: 'devise/registrations/step1'
      end
    end
  end

  alias_method :twitter, :callback_for_all_providers
  alias_method :github, :callback_for_all_providers
  alias_method :google, :callback_for_all_providers

  def passthru
    super
  end

  def failure
    if user_signed_in?
      redirect_to authenticated_root_url
    else
      redirect_to unauthenticated_root_url
    end
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
end
