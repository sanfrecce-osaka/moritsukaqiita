class Users::PasswordsController < Devise::PasswordsController
  def new
    super
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      session[:email] = resource.email
      respond_with(resource, location: after_sending_reset_password_instructions_path_for(resource))
    else
      respond_with(resource)
    end
  end

  def edit
    self.resource = resource_class.check_token(params[:reset_password_token])
    if resource.errors.empty?
      set_minimum_password_length
      session[:original_token] = params[:reset_password_token]
      session[:reset_password_token] = resource.reset_password_token
    else
      redirect_to unauthenticated_root_url, flash: { warning: 'トークンが無効です。' }
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:info, :updated)
      respond_with resource, location: after_resetting_password_path_for(resource)
    elsif resource.errors.details[:reset_password_token].select { |value| value[:error] == :expired }.present?
      redirect_to unauthenticated_root_url, flash: { warning: 'トークンが無効です。' }
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  def sent
    @email = session[:email]
    session.delete(:email)
  end

  protected

  def after_resetting_password_path_for(resource)
    super(resource)
  end

  def after_sending_reset_password_instructions_path_for(resource)
    sent_user_password_path
  end
end
