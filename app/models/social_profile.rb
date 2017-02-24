class SocialProfile < ApplicationRecord
  belongs_to :user

  validates_uniqueness_of :uid, scope: :provider
end
