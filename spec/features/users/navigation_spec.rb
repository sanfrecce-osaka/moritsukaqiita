feature 'ナビゲーションバー（ログイン後）', :devise do
  scenario 'ブランド名、メニューボタンが表示されること' do
    user = create(:user_with_valid_data)
    signin(user.email, user.password)
    expect(page).to have_content 'moritsukaQiita'
    expect(page).to have_content '☰'
  end

  scenario 'メニューボタンを押下するとログアウトのリンクが表示されること', js:true  do
    user = create(:user_with_valid_data)
    signin(user.email, user.password)
    click_link '☰'
    expect(page).to have_content 'ログアウト'
  end
end
