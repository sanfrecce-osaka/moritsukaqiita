module Features
  module SessionHelpers
    def sign_up_with(user_name, email, password)
      visit new_user_registration_path
      fill_in 'ユーザ名', with: user_name
      fill_in 'メールアドレス', with: email
      fill_in 'パスワード', with: password
      click_button '利用規約に同意して登録'
    end

    def signin(login_key, password)
      visit new_user_session_path
      fill_in 'ユーザ名 または メールアドレス', with: login_key
      fill_in 'パスワード', with: password
      click_button 'ログイン'
    end
  end
end
