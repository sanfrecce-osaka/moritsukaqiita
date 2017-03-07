class User::OmniauthPolicyService
  class Base
    attr_reader :provider, :uid, :user_name, :email, :image_url, :access_token, :access_token_secret
  end

  class Twitter < User::OmniauthPolicyService::Base
    def initialize(auth)
      @provider            = auth['provider']
      @uid                 = auth['uid']
      @user_name           = auth['info']['nickname']
      @email               = ''
      @image_url           = auth['info']['image']
      @access_token        = auth['credentials']['token']
      @access_token_secret = auth['credentials']['secret']
      freeze
    end
  end

  class Github < User::OmniauthPolicyService::Base
    def initialize(auth)
      @provider            = auth['provider']
      @uid                 = auth['uid']
      @user_name           = auth['info']['nickname']
      @email               = auth['info']['email']
      @image_url           = auth['info']['image']
      @access_token        = auth['credentials']['token']
      @access_token_secret = ''
      freeze
    end
  end
end
