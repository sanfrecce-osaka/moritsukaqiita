class User < ApplicationRecord
  attr_accessor :login_key

  devise :database_authenticatable, :registerable,
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
      where(conditions).where(['user_name = :value OR lower(email) = lower(:value)', { :value => login_key }]).first
    else
      where(conditions).first
    end
  end
end
