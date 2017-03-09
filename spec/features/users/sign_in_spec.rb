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

      context 'Googleでの認証の場合' do
        given(:provider) { :google }

        scenario 'ログインに成功すること' do
          sign_in_with_omniauth(provider, auth_hash)

          expect(page).to have_content('ログインしました。')
        end
      end
    end

    context 'ユーザ未登録の場合' do
      context 'Twitterでの認証の場合' do
        given(:provider) { :twitter }

        describe '登録画面のフィールドの初期値' do
          scenario '登録画面がユーザ名を入力済かつメールアドレスを入力済かつパスワードのフィールドが非表示の状態で表示されること' do
            sign_in_with_omniauth(provider, auth_hash)

            expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
            expect(page).to have_field 'メールアドレス', with: ''
            expect(page).not_to have_field 'パスワード'
          end
        end
      end

      context 'GitHubでの認証の場合' do
        given(:provider) { :github }

        describe '登録画面のフィールドの初期値' do
          context 'GitHubにメールアドレスが登録されているかつ公開されている場合' do
            scenario '登録画面がユーザ名を入力済かつメールアドレスを入力済かつパスワードのフィールドが非表示の状態で表示されること' do
              sign_in_with_omniauth(provider, auth_hash)

              expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
              expect(page).to have_field 'メールアドレス', with: auth_hash['info']['email']
              expect(page).not_to have_field 'パスワード'
            end
          end

          context 'GitHubにメールアドレスが登録されていないまたは非公開の場合' do
            scenario '登録画面がユーザ名を入力済かつメールアドレスを未入力かつパスワードのフィールドが非表示の状態で表示されること' do
              auth_hash['info']['email'] = nil
              sign_in_with_omniauth(provider, auth_hash)

              expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
              expect(page).to have_field 'メールアドレス', with: ''
              expect(page).not_to have_field 'パスワード'
            end
          end
        end
      end

      context 'Googleでの認証の場合' do
        given(:provider) { :google }

        describe '登録画面のフィールドの初期値' do
          scenario '登録画面がユーザ名を入力済かつメールアドレスを入力済かつパスワードのフィールドが非表示の状態で表示されること' do
            sign_in_with_omniauth(provider, auth_hash)

            expect(page).to have_field 'ユーザ名', with: auth_hash['info']['email'].split('@').first
            expect(page).to have_field 'メールアドレス', with: auth_hash['info']['email']
            expect(page).not_to have_field 'パスワード'
          end
        end
      end
    end
  end
end
