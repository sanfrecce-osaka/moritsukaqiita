class User < ApplicationRecord
  attr_accessor :login_key

  has_many :social_profiles

  devise :database_authenticatable, :omniauthable , :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:login_key]

  validates :user_name,
            presence: true,
            uniqueness: { allow_blank: true },
            length: { in: 3..32, allow_blank: true },
            format: { with: /\A\w(?:\w*|[\w-]*\w)\z/, allow_blank: true, message: 'は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）' }

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login_key = conditions.delete(:login_key)
      where(conditions).where(['user_name = :value OR lower(email) = lower(:value)', { value: login_key }]).first
    else
      where(conditions).first
    end
  end

  def self.check_token(original_token)
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)

    user = find_or_initialize_with_error_by(:reset_password_token, reset_password_token)

    if user.persisted? && user.reset_password_period_valid?
      user.reset_password_token = original_token
    else
      user.errors.add(:reset_password_token, :expired)
    end

    user
  end

  def self.reset_password_by_token(attributes={})
    original_token = attributes[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)

    user = find_or_initialize_with_error_by(:reset_password_token, reset_password_token)

    if user.persisted? && user.reset_password_period_valid?
      user.reset_password_token = original_token
      user.reset_password(attributes[:password])
    else
      user.errors.add(:reset_password_token, :expired)
    end

    user
  end

  def reset_password(new_password)
    self.password = new_password

    save
  end

  def password_required?
    if self.social_profiles.present? && !encrypted_password.present?
      false
    else
      super
    end
  end
end
