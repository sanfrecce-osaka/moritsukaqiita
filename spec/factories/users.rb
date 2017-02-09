FactoryGirl.define {
  factory :user, aliases: [:user_with_valid_data] do
    email 'test0@example.com'
    password 'please12'
    user_name 'ab0'

    factory :user_with_serial_data do
      sequence(:email) { |n| "test#{n}@example.com" }
      sequence(:user_name) { |n| "ab#{n}" }
    end

    factory :user_with_serial_email do
      sequence(:email) { |n| "test#{n}@example.com" }
    end

    factory :user_with_serial_user_name do
      sequence(:user_name) { |n| "ab#{n}" }
    end

    factory :user_with_empty_email do
      email nil
    end

    factory :user_with_empty_user_name do
      user_name nil
    end
  end
}
