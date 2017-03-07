FactoryGirl.define do
  factory :omniauth_hash, aliases: [:twitter_auth_hash], class: Hash do
    provider 'twitter'
    uid { Random.rand(1..100000).to_s }
    info { {
      'nickname' => Faker::Internet.user_name,
      'email' => '',
      'image' => Faker::Internet.url,
    } }
    credentials { {
      'secret' => Faker::Internet.password,
      'token' => Faker::Internet.password
    } }

    factory :github_auth_hash do
      provider 'github'
      info { {
        'nickname' => Faker::Internet.user_name,
        'email' => Faker::Internet.email,
        'image' => Faker::Internet.url,
      } }
      credentials { {
        'secret' => '',
        'token' => Faker::Internet.password
      } }
    end

    initialize_with { attributes }
  end
end
