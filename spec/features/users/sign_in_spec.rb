feature 'ログイン', :devise do
  describe 'ログインキー（メールアドレスかユーザ名）でのログイン' do
    given(:user) { create(:user_with_valid_data) }

    describe 'ログイン成功' do
      scenario 'メールアドレスとパスワードでログインが成功すること' do
        sign_in_with_login_key(user.email, user.password)

        expect(page).to have_content 'ログインしました。'
      end

      scenario 'ユーザ名とパスワードでログインが成功すること' do
        sign_in_with_login_key(user.user_name, user.password)

        expect(page).to have_content 'ログインしました。'
      end
    end

    describe 'エラーメッセージ表示' do
      scenario 'ユーザ登録が未完了の場合、エラーメッセージが表示されること' do
        sign_in_with_login_key('test@example.com', 'please123')

        expect(page).to have_content 'ユーザ名かパスワードが間違っています'
      end

      scenario '未入力の場合、エラーメッセージが表示されること' do
        sign_in_with_login_key('', '')

        expect(page).to have_content 'ユーザ名かパスワードが間違っています'
      end

      scenario '間違ったメールアドレスを入力した場合、エラーメッセージが表示されること' do
        sign_in_with_login_key('invalid@email.com', user.password)

        expect(page).to have_content 'ユーザ名かパスワードが間違っています'
      end

      scenario '間違ったユーザ名を入力した場合、エラーメッセージが表示されること' do
        sign_in_with_login_key('invalidname', user.password)

        expect(page).to have_content 'ユーザ名かパスワードが間違っています'
      end

      scenario '間違ったパスワードを入力した場合、エラーメッセージが表示されること' do
        sign_in_with_login_key(user.email, 'invalidpass')

        expect(page).to have_content 'ユーザ名かパスワードが間違っています'
      end

      given(:user_without_password) { create(:user_with_social_profile, :with_twitter_profile) }

      scenario 'パスワードを設定していないユーザがログインキーでログインしようとした場合、エラーメッセージが表示されること' do
        sign_in_with_login_key(user_without_password.email, '')

        expect(page).to have_content 'パスワードが設定されていないユーザです。TwitterかGitHubでログインしてください。'
      end
    end
  end

  describe 'Omniauthでのログイン' do
    given(:auth_hash) { omniauth_params(provider) }

    context 'ユーザ登録済の場合' do
      given(:user) { build(:user_with_empty_password) }
      given(:profile) { build("profile_with_valid_#{provider.to_s}".to_sym, uid: auth_hash['uid']) }

      background do
        user.social_profiles << profile
        user.save
      end

      context 'Twitterでの認証の場合' do
        given(:provider) { :twitter }

        scenario 'ログインに成功すること' do
          sign_in_with_omniauth(provider, auth_hash)

          expect(page).to have_content('ログインしました。')
        end
      end

      context 'GitHubでの認証の場合' do
        given(:provider) { :github }

        scenario 'ログインに成功すること' do
          sign_in_with_omniauth(provider, auth_hash)

          expect(page).to have_content('ログインしました。')
        end
      end
    end

    context 'ユーザ未登録の場合' do
      context 'Twitterでの認証の場合' do
        given(:provider) { :twitter }

        scenario '登録画面がユーザ名を入力済かつパスワードのフィールドが未表示の状態で表示されること' do
          sign_in_with_omniauth(provider, auth_hash)

          expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
          expect(page).to have_field 'メールアドレス', with: ''
          expect(page).not_to have_field 'パスワード'
        end
      end

      context 'GitHubでの認証の場合' do
        given(:provider) { :github }

        scenario '登録画面がユーザ名を入力済かつパスワードのフィールドが未表示の状態で表示されること' do
          sign_in_with_omniauth(provider, auth_hash)

          expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
          expect(page).to have_field 'メールアドレス', with: auth_hash['info']['email']
          expect(page).not_to have_field 'パスワード'
        end
      end
    end
  end
end
