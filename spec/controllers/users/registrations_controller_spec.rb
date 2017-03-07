describe Users::RegistrationsController do
  describe 'POST create' do
    before { @request.env['devise.mapping'] = Devise.mappings[:user] }

    subject { post :create, params: { user: user_params }, session: session_params }

    describe '通常フォームでの登録' do
      describe '登録成功' do
        let(:user_params) { attributes_for(:user_with_valid_data) }

        context '事前に何もページを閲覧していない場合' do
          let(:session_params) { { user_return_to: nil } }

          example 'Userが1件増えること' do
            expect { subject }.to change(User, :count).by(1)
          end

          example 'SocialProfileが増えないこと' do
            expect { subject }.to change(SocialProfile, :count).by(0)
          end

          example 'トップページへリダイレクトされること' do
            expect(subject).to redirect_to authenticated_root_path
          end
        end

        context '事前にログイン後のみ閲覧できるページにアクセスしていた場合' do
          let(:session_params) { { user_return_to: edit_user_registration_path } }

          example 'Userが1件増えること' do
            expect { subject }.to change(User, :count).by(1)
          end

          example 'SocialProfileが増えないこと' do
            expect { subject }.to change(SocialProfile, :count).by(0)
          end

          example '事前にアクセスしようとしていたページにリダイレクトされること' do
            expect(subject).to redirect_to edit_user_registration_path
          end
        end
      end

      describe '登録失敗' do
        let(:session_params) { nil }
        let(:user_params) { attributes_for(:user_with_valid_data, user_name: 'あ') }

        example 'Userが増えないこと' do
          expect { subject }.to change(User, :count).by(0)
        end

        example 'SocialProfileが増えないこと' do
          expect { subject }.to change(SocialProfile, :count).by(0)
        end

        example 'step1テンプレートがレンダリングされること' do
          expect(subject).to render_template 'devise/registrations/step1'
        end
      end
    end

    describe 'Omniauthでの登録' do
      let(:session_params) { { 'devise.oauth_data' => build("profile_with_valid_#{provider.to_s}").attributes } }

      context 'Twitterでの登録の場合' do
        let(:provider) { :twitter }

        describe '登録成功' do
          let(:user_params) { attributes_for(:user_with_empty_password) }

          example 'Userが1件増えること' do
            expect { subject }.to change(User, :count).by(1)
          end

          example 'SocialProfileが1件増えること' do
            expect { subject }.to change(SocialProfile, :count).by(1)
          end

          example 'トップページへリダイレクトされること' do
            expect(subject).to redirect_to authenticated_root_path
          end
        end

        describe '登録失敗' do
          let(:user_params) { attributes_for(:user_with_empty_password, user_name: 'あ') }

          example 'Userが増えないこと' do
            expect { subject }.to change(User, :count).by(0)
          end

          example 'SocialProfileが増えないこと' do
            expect { subject }.to change(SocialProfile, :count).by(0)
          end

          example 'step1テンプレートがレンダリングされること' do
            expect(subject).to render_template 'devise/registrations/step1'
          end
        end
      end

      context 'GitHubでの登録の場合' do
        let(:provider) { :github }

        describe '登録成功' do
          let(:user_params) { attributes_for(:user_with_empty_password) }

          example 'Userが1件増えること' do
            expect { subject }.to change(User, :count).by(1)
          end

          example 'SocialProfileが1件増えること' do
            expect { subject }.to change(SocialProfile, :count).by(1)
          end

          example 'トップページへリダイレクトされること' do
            expect(subject).to redirect_to authenticated_root_path
          end
        end

        describe '登録失敗' do
          let(:user_params) { attributes_for(:user_with_empty_password, user_name: 'あ') }

          example 'Userが増えないこと' do
            expect { subject }.to change(User, :count).by(0)
          end

          example 'SocialProfileが増えないこと' do
            expect { subject }.to change(SocialProfile, :count).by(0)
          end

          example 'step1テンプレートがレンダリングされること' do
            expect(subject).to render_template 'devise/registrations/step1'
          end
        end
      end
    end
  end
end
