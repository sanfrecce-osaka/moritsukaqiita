class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  after_action :store_location

  def store_location
    if (request.fullpath != '/users/sign_in' &&
        request.fullpath != '/users/sign_up' &&
        request.fullpath != '/users/password' &&
        !request.xhr?)
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || authenticated_root_path
  end

  def after_sign_out_path_for(resource)
    session[:previous_url] || unauthenticated_root_path
  end
end
