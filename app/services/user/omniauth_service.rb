class User::OmniauthService
  def initialize(auth)
    @auth = auth
  end

  def find_or_build_for_omniauth
    profile = SocialProfile.where(provider: @auth['provider'], uid: @auth['uid']).first
    unless profile
      profile = build_omniauth_data
    end
    profile
  end

  private

  def build_omniauth_data
    class_name = "#{@auth['provider']}".classify
    policy = "User::OmniauthPolicyService::#{class_name}".constantize.new(@auth)
    SocialProfile.new(provider:            policy.provider,
                      uid:                 policy.uid,
                      user_name:           policy.user_name,
                      email:               policy.email,
                      image_url:           policy.image_url,
                      access_token:        policy.access_token,
                      access_token_secret: policy.access_token_secret)
  end
end
