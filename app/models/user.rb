class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :user_name,
            presence: true,
            uniqueness: { allow_blank: true },
            length: { in: 3..32, allow_blank: true },
            format: { with: /\A\w(?:\w*|[\w-]*\w)\z/, allow_blank: true, message: 'は半角英数字及び_, -のみ利用可能です。（-は先頭と末尾には使えません）' }
end
