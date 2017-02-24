class CreateSocialProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :social_profiles do |t|
      t.references :user, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :user_name
      t.string :email
      t.string :image_url
      t.string :access_token
      t.string :access_token_secret

      t.timestamps
    end
    add_index :social_profiles, [:provider, :uid], unique: true
  end
end
