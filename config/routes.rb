Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions:      'users/sessions',
    registrations: 'users/registrations',
    passwords:     'users/passwords',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  devise_scope :user do
    get '/users/password/sent', to: 'users/passwords#sent', as: :sent_user_password
    authenticated :user do
      root to: 'tips#index', as: :authenticated_root
    end
    unauthenticated :user do
      root to: 'users/sessions#new', as: :unauthenticated_root
    end
  end
end
