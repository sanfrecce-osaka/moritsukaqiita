describe User::OmniauthService do
  let(:service) { User::OmniauthService.new(params) }

  describe '#find_or_build_for_omniauth' do
    describe '戻り値の検証' do
      let(:profile) { service.find_or_build_for_omniauth }

      context '渡されたSNSの情報がDBに保存済の場合' do
        let(:expected_attributes) do
          user = create(:user_with_social_profile, :with_twitter_profile)
          user.social_profiles.first.attributes
        end
        let(:params) do
          params                = {}
          params['provider']    = expected_attributes['provider']
          params['uid']         = expected_attributes['uid']
          info                  = params['info'] = {}
          info['nickname']      = expected_attributes['user_name']
          info['email']         = expected_attributes['email']
          info['image']         = expected_attributes['image_url']
          credentials           = params['credentials'] = {}
          credentials['token']  = expected_attributes['access_token']
          credentials['secret'] = expected_attributes['access_token_secret']

          params
        end

        subject { profile }

        it { is_expected.to have_attributes(expected_attributes) }
        it { is_expected.to be_persisted }
      end

      context '渡されたSNSの情報がDBに保存されていなかった場合' do
        let(:expected_attributes) do
          expected_attributes                       = {}
          expected_attributes[:provider]            = params['provider']
          expected_attributes[:uid]                 = params['uid']
          expected_attributes[:user_name]           = params['info']['nickname']
          expected_attributes[:email]               = ''
          expected_attributes[:image_url]           = params['info']['image']
          expected_attributes[:access_token]        = params['credentials']['token']
          expected_attributes[:access_token_secret] = params['credentials']['secret']

          expected_attributes
        end
        let(:params) { build(:twitter_auth_hash).map { |key, value| [key.to_s, value] }.to_h }

        subject { profile }

        it { is_expected.to have_attributes(expected_attributes) }
        it { is_expected.not_to be_persisted }
      end
    end
  end

  describe '#build_omniauth_data' do
    let(:params) { build("#{provider.to_s}_auth_hash".to_sym).map { |key, value| [key.to_s, value] }.to_h }
    let(:profile) { service.send(:build_omniauth_data) }

    describe 'ポリシーに沿って値が格納されているかの検証' do
      context '渡された情報がTwitterの情報だった場合' do
        let(:provider) { :twitter }
        let(:expected_attributes) do
          expected_attributes                       = {}
          expected_attributes[:provider]            = params['provider']
          expected_attributes[:uid]                 = params['uid']
          expected_attributes[:user_name]           = params['info']['nickname']
          expected_attributes[:email]               = ''
          expected_attributes[:image_url]           = params['info']['image']
          expected_attributes[:access_token]        = params['credentials']['token']
          expected_attributes[:access_token_secret] = params['credentials']['secret']

          expected_attributes
        end

        subject { profile }

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context '渡された情報がGitHubの情報だった場合' do
        let(:provider) { :github }
        let(:expected_attributes) do
          expected_attributes                       = {}
          expected_attributes[:provider]            = params['provider']
          expected_attributes[:uid]                 = params['uid']
          expected_attributes[:user_name]           = params['info']['nickname']
          expected_attributes[:email]               = params['info']['email']
          expected_attributes[:image_url]           = params['info']['image']
          expected_attributes[:access_token]        = params['credentials']['token']
          expected_attributes[:access_token_secret] = ''

          expected_attributes
        end

        subject { profile }

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context '渡された情報がGoogleの情報だった場合' do
        let(:provider) { :google }
        let(:expected_attributes) do
          expected_attributes                       = {}
          expected_attributes[:provider]            = params['provider']
          expected_attributes[:uid]                 = params['uid']
          expected_attributes[:user_name]           = params['info']['email'].split('@').first
          expected_attributes[:email]               = params['info']['email']
          expected_attributes[:image_url]           = params['info']['image']
          expected_attributes[:access_token]        = params['credentials']['token']
          expected_attributes[:access_token_secret] = ''

          expected_attributes
        end

        subject { profile }

        it { is_expected.to have_attributes(expected_attributes) }
      end
    end
  end
end
