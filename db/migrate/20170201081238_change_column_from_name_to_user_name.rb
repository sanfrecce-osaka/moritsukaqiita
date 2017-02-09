class ChangeColumnFromNameToUserName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :name, :user_name
    change_column :users, :user_name, :string, null: false, default: ''
    add_index :users, :user_name, unique: true
  end
end
