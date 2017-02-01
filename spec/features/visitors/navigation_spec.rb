# Feature: Navigation links
#   As a visitor
#   I want to see navigation links
#   So I can find home, sign in, or sign up
feature 'Navigation links for visitors', :devise do

  # Scenario: View navigation links
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "home," "sign in," and "sign up"
  scenario 'view navigation links' do
    visit unauthenticated_root_path
    expect(page).to have_content 'moritsukaQiita'
    expect(page).to have_content 'ユーザ登録'
    expect(page).to have_content 'ログイン'
  end

end
