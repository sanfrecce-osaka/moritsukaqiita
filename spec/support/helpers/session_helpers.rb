module Features
  module SessionHelpers
    def sign_up_with_password(user_name, email, password)
      visit new_user_registration_path
      fill_in 'ユーザ名', with: user_name
      fill_in 'メールアドレス', with: email
      fill_in 'パスワード', with: password
      click_button '利用規約に同意して登録'
    end

    def sign_in_with_login_key(login_key, password)
      visit new_user_session_path
      fill_in 'ユーザ名 または メールアドレス', with: login_key
      fill_in 'パスワード', with: password
      click_button 'ログイン'
    end

    def sign_up_with_omniauth(provider, params = nil)
      visit new_user_registration_path
      OmniAuth.config.mock_auth[provider] = build_authhash(params)
      case provider
      when :twitter
        click_link 'Twitterアカウントで登録'
      end
    end

    def sign_in_with_omniauth(provider, params)
      visit new_user_session_path
      OmniAuth.config.mock_auth[provider] = build_authhash(params)
      case provider
      when :twitter
        click_link 'Twitterアカウントでログイン'
      end
    end

    def build_authhash(params)
      OmniAuth.config.test_mode = true
      OmniAuth::AuthHash.new(params)
    end

    def omniauth_params(provider)
      build("#{provider.to_s}_auth_hash".to_sym).map { |key, value| [key.to_s, value] }.to_h
    end
  end
end
