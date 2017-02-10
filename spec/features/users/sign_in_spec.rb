feature 'ログイン', :devise do
  let(:user) { create(:user_with_valid_data) }

  scenario 'ユーザ登録が未完了の場合、エラーメッセージが表示されること' do
    signin('test@example.com', 'please123')
    expect(page).to have_content 'ユーザ名かパスワードが間違っています'
  end

  scenario 'メールアドレスとパスワードでログインが成功すること' do
    signin(user.email, user.password)
    expect(page).to have_content 'ログインしました。'
  end

  scenario 'ユーザ名とパスワードでログインが成功すること' do
    signin(user.user_name, user.password)
    expect(page).to have_content 'ログインしました。'
  end

  scenario '未入力の場合、エラーメッセージが表示されること' do
    signin('', '')
    expect(page).to have_content 'ユーザ名かパスワードが間違っています'
  end

  scenario '間違ったメールアドレスを入力した場合、エラーメッセージが表示されること' do
    signin('invalid@email.com', user.password)
    expect(page).to have_content 'ユーザ名かパスワードが間違っています'
  end

  scenario '間違ったユーザ名を入力した場合、エラーメッセージが表示されること' do
    signin('invalidname', user.password)
    expect(page).to have_content 'ユーザ名かパスワードが間違っています'
  end

  scenario '間違ったパスワードを入力した場合、エラーメッセージが表示されること' do
    signin(user.email, 'invalidpass')
    expect(page).to have_content 'ユーザ名かパスワードが間違っています'
  end
end
