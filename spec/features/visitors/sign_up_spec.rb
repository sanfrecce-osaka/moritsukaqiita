feature 'ユーザ登録', :devise do
  given(:valid_user_name) { '123' }
  given(:valid_email) { 'test@example.com' }
  given(:valid_password) { '12345678' }

  scenario '正常終了' do
    sign_up_with(valid_user_name, valid_email, valid_password)
    expect(page).to have_content('アカウント登録を受け付けました。')
  end

  scenario 'ユーザ名が未入力の場合、存在チェックのエラーメッセージのみが表示される' do
    sign_up_with('', valid_email, valid_password)
    expect(page).to have_content('ユーザ名が入力されていません。')
    expect(page).not_to have_content('ユーザ名 はすでに存在しています。')
    expect(page).not_to have_content('ユーザ名は3文字以上で入力してください。')
    expect(page).not_to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
  end

  scenario 'ユーザ名が3文字未満かつフォーマットが不正の場合、フォーマットチェックと長さチェックの両方のエラーメッセージが表示される' do
    sign_up_with('あ', valid_email, valid_password)
    expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
    expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
  end

  scenario 'ユーザ名が3文字未満かつフォーマットが正しい場合、長さチェックのエラーメッセージのみが表示される' do
    sign_up_with('ab', valid_email, valid_password)
    expect(page).to have_content('ユーザ名は3文字以上で入力してください。')
    expect(page).not_to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
  end

  scenario 'ユーザ名が33文字以上の場合、長さチェックのエラーメッセージが表示される' do
    sign_up_with('123456789012345678901234567890123', valid_email, valid_password)
    expect(page).to have_content('ユーザ名は32文字以内で入力してください。')
  end

  scenario 'ユーザ名のフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示される。' do
    sign_up_with('-aZ', valid_email, valid_password)
    expect(page).to have_content('ユーザ名は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）')
  end

  scenario 'ユーザ名が登録済みの場合、一意性チェックのエラーメッセージが表示される', js: true do
    sign_up_with(valid_user_name, valid_email, valid_password)
    click_link '☰'
    click_link 'ログアウト'
    sign_up_with(valid_user_name, 'test1@example.com', valid_password)
    expect(page).to have_content('ユーザ名 123 はすでに存在します。')
  end

  scenario 'メールアドレスが未入力の場合、存在チェックのエラーメッセージが表示される' do
    sign_up_with(valid_user_name, '', valid_password)
    expect(page).to have_content('メールアドレスが入力されていません。')
  end

  scenario 'メールアドレスのフォーマットが不正の場合、フォーマットチェックのエラーメッセージが表示される' do
    sign_up_with(valid_user_name, 'test', valid_password)
    expect(page).to have_content('メールアドレスのフォーマットが正しくありません。')
  end

  scenario 'メールアドレスが登録済みの場合、一意性チェックのエラーメッセージが表示される', js: true do
    sign_up_with(valid_user_name, valid_email, valid_password)
    click_link '☰'
    click_link 'ログアウト'
    sign_up_with('1234', valid_email, valid_password)
    expect(page).to have_content('メールアドレス test@example.com はすでに存在します。')
  end

  scenario 'パスワードが未入力の場合、存在チェックのエラーメッセージが表示される' do
    sign_up_with(valid_user_name, valid_email, '')
    expect(page).to have_content('パスワードが入力されていません。')
  end

  scenario 'パスワードが8文字未満の場合、長さチェックのエラーメッセージが表示される' do
    sign_up_with(valid_user_name, valid_email, '1234567')
    expect(page).to have_content('パスワードは8文字以上で入力してください。')
  end

  scenario 'パスワードが33文字以上の場合、長さチェックのエラーメッセージが表示される' do
    sign_up_with(valid_user_name, valid_email, '123456789012345678901234567890123')
    expect(page).to have_content('パスワードは32文字以内で入力してください。')
  end
end
