describe Users::OmniauthCallbacksController do
  let(:auth_hash) { build("#{provider.to_s}_auth_hash".to_sym).map { |k, v| [k.to_s, v] }.to_h }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.env['omniauth.auth']  = auth_hash
  end

  describe 'GET twitter' do
    let(:provider) { :twitter }

    subject { get provider, session: session_params }

    context 'SNSの情報が保存済の場合' do
      let(:user) { build(:user_with_empty_password) }
      let(:profile) { build(:profile_with_valid_twitter, uid: auth_hash['uid']) }

      before do
        user.social_profiles << profile
        user.save
      end

      context '事前に何もページを閲覧していない場合' do
        let(:session_params) { { user_return_to: nil } }

        example 'トップページにリダイレクトされること' do
          expect(subject).to redirect_to(authenticated_root_path)
        end
      end

      context '事前にログイン後のみ閲覧できるページにアクセスしていた場合' do
        let(:session_params) { { user_return_to: edit_user_registration_path } }

        example '事前にアクセスしようとしていたページにリダイレクトされること' do
          expect(subject).to redirect_to(edit_user_registration_path)
        end
      end
    end

    context 'SNSの情報が保存されていなかった場合' do
      context 'ログインしている場合' do
        let(:user) { create(:user_with_valid_data) }
        let(:session_params) { { previous_url: authenticated_root_path } }

        before { sign_in user }

        example 'SocialProfileが1件増えること' do
          expect { subject }.to change(SocialProfile, :count).by(1)
        end

        example 'Omniauth認証する前のページにリダイレクトされること' do
          expect(subject).to redirect_to authenticated_root_path
        end
      end

      context 'ログインしていない場合' do
        let(:session_params) { nil }

        example 'インスタンス変数@userがtwitterのユーザ名と空のメールアドレスを持つこと' do
          get provider
          expect(assigns(:user)).to have_attributes user_name: auth_hash['info']['nickname']
          expect(assigns(:user)).to have_attributes email: ''
        end

        example 'step1テンプレートがレンダリングされること' do
          expect(subject).to render_template 'devise/registrations/step1'
        end
      end
    end
  end

  describe 'GET github' do
    let(:provider) { :github }

    subject { get provider, session: session_params }

    context 'SNSの情報が保存済の場合' do
      let(:user) { build(:user_with_empty_password) }
      let(:profile) { build(:profile_with_valid_github, uid: auth_hash['uid']) }

      before do
        user.social_profiles << profile
        user.save
      end

      context '事前に何もページを閲覧していない場合' do
        let(:session_params) { { user_return_to: nil } }

        example 'トップページにリダイレクトされること' do
          expect(subject).to redirect_to(authenticated_root_path)
        end
      end

      context '事前にログイン後のみ閲覧できるページにアクセスしていた場合' do
        let(:session_params) { { user_return_to: edit_user_registration_path } }

        example '事前にアクセスしようとしていたページにリダイレクトされること' do
          expect(subject).to redirect_to(edit_user_registration_path)
        end
      end
    end

    context 'SNSの情報が保存されていなかった場合' do
      context 'ログインしている場合' do
        let(:user) { create(:user_with_valid_data) }
        let(:session_params) { { previous_url: authenticated_root_path } }

        before { sign_in user }

        example 'SocialProfileが1件増えること' do
          expect { subject }.to change(SocialProfile, :count).by(1)
        end

        example 'Omniauth認証する前のページにリダイレクトされること' do
          expect(subject).to redirect_to authenticated_root_path
        end
      end

      context 'ログインしていない場合' do
        let(:session_params) { nil }

        example 'インスタンス変数@userがgithubのユーザ名と空のメールアドレスを持つこと' do
          get provider
          expect(assigns(:user)).to have_attributes user_name: auth_hash['info']['nickname']
          expect(assigns(:user)).to have_attributes email: auth_hash['info']['email']
        end

        example 'step1テンプレートがレンダリングされること' do
          expect(subject).to render_template 'devise/registrations/step1'
        end
      end
    end
  end
end
