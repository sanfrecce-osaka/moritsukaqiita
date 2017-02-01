feature 'Navigation links for users', :devise do

  scenario 'view navigation links' , js:true do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    expect(page).to have_content 'moritsukaQiita'
    expect(page).to have_content '☰'
    click_link '☰'
    expect(page).to have_content 'ログアウト'
    #take_screenshot
  end

end
