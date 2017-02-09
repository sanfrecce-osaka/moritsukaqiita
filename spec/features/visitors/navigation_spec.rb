feature 'ナビゲーションバー（ログイン前）', :devise do
  scenario 'ブランド名、ユーザ登録ボタン、ログインのリンクが表示されること' do
    visit unauthenticated_root_path
    expect(page).to have_content 'moritsukaQiita'
    expect(page).to have_content 'ユーザ登録'
    expect(page).to have_content 'ログイン'
  end
end
