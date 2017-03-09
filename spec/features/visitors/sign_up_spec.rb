feature 'ユーザ登録', :devise do
  given(:valid_user_name) { '123' }
  given(:valid_email) { 'test@example.com' }
  given(:valid_password) { '12345678' }

  describe '通常フォームでの登録' do
    describe '登録成功' do
      scenario 'ユーザ名、メールアドレス、パスワードの入力で登録が完了すること' do
        sign_up_with_password(valid_user_name, valid_email, valid_password)

        expect(page).to have_content('Welcome to moritsukaQiita!')
      end
    end

    describe 'エラーメッセージ表示' do
      scenario 'ユーザ名が未入力の場合、存在チェックのエラーメッセージのみが表示されること' do
        sign_up_with_password('', valid_email, valid_password)

        expect(page).to have_content('ユーザ名が入力されていません。')
        expect(page).not_to have_content('ユーザ名 はすでに存在しています。')
        expect(page).not_to have_content('ユーザ名は3文字以上で入力してください。')
        expect(page).not_to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
      end

      scenario 'ユーザ名が3文字未満かつフォーマットが不正の場合、フォーマットチェックと長さチェックの両方のエラーメッセージが表示されること' do
        sign_up_with_password('あ', valid_email, valid_password)

        expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
        expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
      end

      scenario 'ユーザ名が3文字未満かつフォーマットが正しい場合、長さチェックのエラーメッセージのみが表示されること' do
        sign_up_with_password('ab', valid_email, valid_password)

        expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
        expect(page).not_to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
      end

      scenario 'ユーザ名が33文字以上の場合、長さチェックのエラーメッセージが表示される' do
        sign_up_with_password('123456789012345678901234567890123', valid_email, valid_password)

        expect(page).to have_content('ユーザ名は32文字以内で入力してください。')
      end

      scenario 'ユーザ名のフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示されること' do
        sign_up_with_password('-aZ', valid_email, valid_password)

        expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
      end

      scenario 'ユーザ名が登録済みの場合、一意性チェックのエラーメッセージが表示されること', js: true do
        sign_up_with_password(valid_user_name, valid_email, valid_password)

        click_link '☰'
        click_link 'ログアウト'

        sign_up_with_password(valid_user_name, 'test1@example.com', valid_password)

        expect(page).to have_content('ユーザ名 123 はすでに存在します。')
      end

      scenario 'メールアドレスが未入力の場合、存在チェックのエラーメッセージが表示されること' do
        sign_up_with_password(valid_user_name, '', valid_password)

        expect(page).to have_content('メールアドレスが入力されていません。')
      end

      scenario 'メールアドレスのフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示されること' do
        sign_up_with_password(valid_user_name, 'test', valid_password)

        expect(page).to have_content('メールアドレスのフォーマットが正しくありません。')
      end

      scenario 'メールアドレスが登録済みの場合、一意性チェックのエラーメッセージが表示されること', js: true do
        sign_up_with_password(valid_user_name, valid_email, valid_password)

        click_link '☰'
        click_link 'ログアウト'

        sign_up_with_password('1234', valid_email, valid_password)

        expect(page).to have_content('メールアドレス test@example.com はすでに存在します。')
      end

      scenario 'パスワードが未入力の場合、存在チェックのエラーメッセージが表示されること' do
        sign_up_with_password(valid_user_name, valid_email, '')

        expect(page).to have_content('パスワードが入力されていません。')
      end

      scenario 'パスワードが8文字未満の場合、長さチェックのエラーメッセージが表示されること' do
        sign_up_with_password(valid_user_name, valid_email, '1234567')

        expect(page).to have_content('パスワードは8文字以上で入力してください。')
      end

      scenario 'パスワードが33文字以上の場合、長さチェックのエラーメッセージが表示されること' do
        sign_up_with_password(valid_user_name, valid_email, '123456789012345678901234567890123')

        expect(page).to have_content('パスワードは32文字以内で入力してください。')
      end
    end
  end

  describe 'Omniauthでの登録' do
    given(:auth_hash) { omniauth_params(provider) }

    context 'ユーザ未登録の場合' do
      context 'Twitterでの認証の場合' do
        given(:provider) { :twitter }

        describe '登録画面のフィールドの初期値' do
          scenario '登録画面がユーザ名を入力済かつメールアドレスを未入力かつパスワードのフィールドが非表示の状態で表示されること' do
            sign_up_with_omniauth(provider, auth_hash)

            expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
            expect(page).to have_field 'メールアドレス', with: ''
            expect(page).not_to have_field 'パスワード'
          end
        end

        describe '登録成功' do
          scenario 'Twitter認証 > ユーザ名変更、メールアドレス入力 > 登録完了' do
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: valid_user_name
            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content 'Welcome to moritsukaQiita!'
          end
        end

        describe 'エラーメッセージ表示' do
          scenario 'ユーザ名が3文字未満かつフォーマットが不正の場合、フォーマットチェックと長さチェックの両方のエラーメッセージが表示されること' do
            auth_hash['info']['nickname'] = '.c'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
            expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が3文字未満かつフォーマットが正しい場合、長さチェックのエラーメッセージのみが表示されること' do
            auth_hash['info']['nickname'] = 'ab'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
            expect(page).not_to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が33文字以上の場合、長さチェックのエラーメッセージが表示される' do
            auth_hash['info']['nickname'] = '123456789012345678901234567890123'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は32文字以内で入力してください。')
          end

          scenario 'ユーザ名のフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示されること' do
            auth_hash['info']['nickname'] = '-aZ'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が登録済みの場合、一意性チェックのエラーメッセージが表示されること', js: true do
            sign_up_with_password(valid_user_name, valid_email, valid_password)

            click_link '☰'
            click_link 'ログアウト'

            auth_hash['info']['nickname'] = valid_user_name
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: 'test1@example.com'
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名 123 はすでに存在します。')
          end
        end
      end

      context 'GitHubでの認証の場合' do
        given(:provider) { :github }

        describe '登録画面のフィールドの初期値' do
          context 'GitHubにメールアドレスが登録されているかつ公開されている場合' do
            scenario '登録画面がユーザ名を入力済かつメールアドレスを入力済かつパスワードのフィールドが非表示の状態で表示されること' do
              sign_up_with_omniauth(provider, auth_hash)

              expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
              expect(page).to have_field 'メールアドレス', with: auth_hash['info']['email']
              expect(page).not_to have_field 'パスワード'
            end
          end

          context 'GitHubにメールアドレスが登録されていないまたは非公開の場合' do
            scenario '登録画面がユーザ名を入力済かつメールアドレスを未入力、パスワードのフィールドが非表示の状態で表示されること' do
              auth_hash['info']['email'] = nil
              sign_up_with_omniauth(provider, auth_hash)

              expect(page).to have_field 'ユーザ名', with: auth_hash['info']['nickname']
              expect(page).to have_field 'メールアドレス', with: ''
              expect(page).not_to have_field 'パスワード'
            end
          end
        end

        describe '登録成功' do
          scenario 'GitHub認証 > ユーザ名変更、メールアドレス変更 > 登録完了' do
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: valid_user_name
            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content 'Welcome to moritsukaQiita!'
          end
        end

        describe 'エラーメッセージ表示' do
          scenario 'ユーザ名が3文字未満かつフォーマットが不正の場合、フォーマットチェックと長さチェックの両方のエラーメッセージが表示されること' do
            auth_hash['info']['nickname'] = '.c'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
            expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が3文字未満かつフォーマットが正しい場合、長さチェックのエラーメッセージのみが表示されること' do
            auth_hash['info']['nickname'] = 'ab'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
            expect(page).not_to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が33文字以上の場合、長さチェックのエラーメッセージが表示される' do
            auth_hash['info']['nickname'] = '123456789012345678901234567890123'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は32文字以内で入力してください。')
          end

          scenario 'ユーザ名のフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示されること' do
            auth_hash['info']['nickname'] = '-aZ'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が登録済みの場合、一意性チェックのエラーメッセージが表示されること', js: true do
            sign_up_with_password(valid_user_name, valid_email, valid_password)

            click_link '☰'
            click_link 'ログアウト'

            auth_hash['info']['nickname'] = valid_user_name
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: 'test1@example.com'
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名 123 はすでに存在します。')
          end

          scenario 'メールアドレスが未入力の場合、存在チェックのエラーメッセージが表示されること' do
            auth_hash['info']['email'] = ''
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: valid_user_name
            click_button '利用規約に同意して登録'

            expect(page).to have_content('メールアドレスが入力されていません。')
          end

          scenario 'メールアドレスのフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示されること' do
            auth_hash['info']['email'] = 'foo@bar_baz.com'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: valid_user_name
            click_button '利用規約に同意して登録'

            expect(page).to have_content('メールアドレスのフォーマットが正しくありません。')
          end

          scenario 'メールアドレスが登録済みの場合、一意性チェックのエラーメッセージが表示されること', js: true do
            sign_up_with_password(valid_user_name, valid_email, valid_password)

            click_link '☰'
            click_link 'ログアウト'

            auth_hash['info']['email'] = valid_email
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: 'test1'
            click_button '利用規約に同意して登録'

            expect(page).to have_content('メールアドレス test@example.com はすでに存在します。')
          end
        end
      end

      context 'Googleでの認証の場合' do
        given(:provider) { :google }

        describe '登録画面のフィールドの初期値' do
          scenario '登録画面がユーザ名を入力済かつメールアドレスを入力済かつパスワードのフィールドが非表示の状態で表示されること' do
            sign_up_with_omniauth(provider, auth_hash)

            expect(page).to have_field 'ユーザ名', with: auth_hash['info']['email'].split('@').first
            expect(page).to have_field 'メールアドレス', with: auth_hash['info']['email']
            expect(page).not_to have_field 'パスワード'
          end
        end

        describe '登録成功' do
          scenario 'GitHub認証 > ユーザ名変更、メールアドレス変更 > 登録完了' do
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: valid_user_name
            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content 'Welcome to moritsukaQiita!'
          end
        end

        describe 'エラーメッセージ表示' do
          scenario 'ユーザ名が3文字未満かつフォーマットが不正の場合、フォーマットチェックと長さチェックの両方のエラーメッセージが表示されること' do
            auth_hash['info']['email'] = '.c@test.com'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
            expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が3文字未満かつフォーマットが正しい場合、長さチェックのエラーメッセージのみが表示されること' do
            auth_hash['info']['email'] = 'ab@test.com'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
            expect(page).not_to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が33文字以上の場合、長さチェックのエラーメッセージが表示される' do
            auth_hash['info']['email'] = '123456789012345678901234567890123@test.com'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は32文字以内で入力してください。')
          end

          scenario 'ユーザ名のフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示されること' do
            auth_hash['info']['email'] = '-aZ@test.com'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: valid_email
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
          end

          scenario 'ユーザ名が登録済みの場合、一意性チェックのエラーメッセージが表示されること', js: true do
            sign_up_with_password(valid_email.split('@').first, valid_email, valid_password)

            click_link '☰'
            click_link 'ログアウト'

            auth_hash['info']['email'] = valid_email
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'メールアドレス', with: 'test1@example.com'
            click_button '利用規約に同意して登録'

            expect(page).to have_content('ユーザ名 test はすでに存在します。')
          end

          scenario 'メールアドレスが未入力の場合、存在チェックのエラーメッセージが表示されること' do
            auth_hash['info']['email'] = ''
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: valid_user_name
            click_button '利用規約に同意して登録'

            expect(page).to have_content('メールアドレスが入力されていません。')
          end

          scenario 'メールアドレスのフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示されること' do
            auth_hash['info']['email'] = 'foo@bar_baz.com'
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: valid_user_name
            click_button '利用規約に同意して登録'

            expect(page).to have_content('メールアドレスのフォーマットが正しくありません。')
          end

          scenario 'メールアドレスが登録済みの場合、一意性チェックのエラーメッセージが表示されること', js: true do
            sign_up_with_password(valid_user_name, valid_email, valid_password)

            click_link '☰'
            click_link 'ログアウト'

            auth_hash['info']['email'] = valid_email
            sign_up_with_omniauth(provider, auth_hash)

            fill_in 'ユーザ名', with: 'test1'
            click_button '利用規約に同意して登録'

            expect(page).to have_content('メールアドレス test@example.com はすでに存在します。')
          end
        end
      end
    end

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
          sign_up_with_omniauth(provider, auth_hash)

          expect(page).to have_content('ログインしました。')
        end
      end

      context 'GitHubでの認証の場合' do
        given(:provider) { :github }

        scenario 'ログインに成功すること' do
          sign_up_with_omniauth(provider, auth_hash)

          expect(page).to have_content('ログインしました。')
        end
      end

      context 'Googleでの認証の場合' do
        given(:provider) { :google }

        scenario 'ログインに成功すること' do
          sign_up_with_omniauth(provider, auth_hash)

          expect(page).to have_content('ログインしました。')
        end
      end
    end
  end
end
