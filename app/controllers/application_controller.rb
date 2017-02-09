class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  after_action :store_location

  def store_location
    if request.fullpath != '/users/sign_in' &&
      request.fullpath != '/users/sign_up' &&
      request.fullpath !~ Regexp.new("\\A/users/password.*\\z") &&
      !request.xhr?
      session[:previous_url] = request.fullpath if request.get?
    end
  end
end
