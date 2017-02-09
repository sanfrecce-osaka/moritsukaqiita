describe User do
  let(:user) { build(:user_with_valid_data) }
  let(:upper_case_email) { user.email.upcase }

  describe 'バリデーション' do
    describe '#email' do
      describe '正常終了' do
        it { expect(user).to be_valid }
      end

      describe '存在チェック' do
        it { is_expected.to validate_presence_of(:email) }
      end

      describe '一意性チェック' do
        before { create(:user_with_serial_user_name) }
        context '全く同一の場合' do
          it { expect(user).not_to be_valid }
        end

        context '全て小文字と全て大文字の場合' do
          it { expect(build(:user_with_serial_user_name, email: upper_case_email)).not_to be_valid }
        end
      end

      describe 'フォーマットチェック' do
        context '有効なフォーマットの場合' do
          valid_emails = %w(
            user@foo.COM
            A_US-ER@f.b.org
            frst.lst@foo.jp
            a+b@baz.cn
          )
          it { is_expected.to allow_value(*valid_emails).for(:email) }
        end

        context '無効なフォーマットの場合' do
          invalid_emails = %w(
            user@foo,com
            user_at_foo.org
            example.user@foo.
            foo@bar_baz.com
            foo@bar+baz.com
          )
          it { is_expected.not_to allow_value(*invalid_emails).for(:email) }
        end
      end
    end

    describe '#password' do
      describe '存在チェック' do
        it { is_expected.to validate_presence_of(:password) }
      end

      describe '長さチェック' do
        it { is_expected.to validate_length_of(:password).is_at_least(8).is_at_most(32) }
      end
    end

    describe '#user_name' do
      describe '存在チェック' do
        it { is_expected.to validate_presence_of(:user_name) }
      end

      describe '一意性チェック' do
        it { is_expected.to validate_uniqueness_of(:user_name) }
      end

      describe '長さチェック' do
        it { is_expected.to validate_length_of(:user_name).is_at_least(3).is_at_most(32) }
      end

      describe 'フォーマットチェック' do
        context '有効なフォーマットの場合' do
          valid_user_names = %w(
            _a_
            A-C
            izA-q
            Ichiro_Suzuki
          )
          it { is_expected.to allow_value(*valid_user_names).for(:user_name) }
        end

        context '無効なフォーマットの場合' do
          invalid_user_names = %w(
            -a
            A-
            テスト
            @aC
            [abc]
            m@suo
            nihon¥
            (AB)C
            question?
            !EXIT
            3.14
            #twitter
            usa$
          )
          it { is_expected.not_to allow_value(*invalid_user_names).for(:user_name) }
        end
      end
    end
  end

  describe 'データベース' do
    before { user.save }
    describe 'email' do
      describe 'NOT NULL制約' do
        it { expect{ build(:user_with_empty_email).save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid) }
      end

      describe 'UNIQUE制約' do
        it { expect{ build(:user_with_serial_user_name).save!(validate:false) }.to raise_error(ActiveRecord::RecordNotUnique) }
      end
    end

    describe 'user_name' do
      describe 'NOT NULL制約' do
        it { expect{ build(:user_with_empty_user_name).save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid) }
      end

      describe 'UNIQUE制約' do
        it { expect{ build(:user_with_serial_email).save!(validate:false) }.to raise_error(ActiveRecord::RecordNotUnique) }
      end
    end
  end
end
