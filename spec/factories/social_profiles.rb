FactoryGirl.define do
  factory :social_profile, aliases: [:profile_with_valid_twitter] do
    provider 'twitter'
    uid 'test_uid0'
    user_name 'test0'
    email ''
    image_url 'http://test.com'
    access_token 'test_access_token0'
    access_token_secret 'test_access_token_secret0'

    factory :profile_with_valid_github do
      provider 'github'
      email 'test0@test.com'
      access_token_secret ''

      factory :profile_with_valid_google do
        provider 'google'
      end
    end
  end
end
