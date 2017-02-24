describe SocialProfile do
  let(:user) { build(:user_with_social_profile, :with_twitter_profile) }
  let(:twitter) { build(:profile_with_valid_twitter) }
  let(:github) { build(:profile_with_valid_github) }

  describe 'バリデーション' do
    describe '#uid' do
      describe '一意性チェック' do
        before { user.save }

        context 'providerが同一の場合' do
          before { user.social_profiles << twitter }

          it { expect(user).not_to be_valid }
        end

        context 'providerが異なる場合' do
          before { user.social_profiles << github }

          it { expect(user).to be_valid }
        end
      end
    end
  end

  describe 'データベース' do
    before { user.save }

    describe 'UNIQUE制約' do
      before { twitter.user = user }

      it { expect { twitter.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid) }
    end

    describe 'FOREIGN KEY制約' do
      before do
        @profile         = user.social_profiles.first
        @profile.user_id = 99999
      end

      it { expect { @profile.save!(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey) }
    end
  end
end
