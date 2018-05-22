class AddOpenidToSpreeUser < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :openid, :string, limit: 128
    add_column :spree_users, :nickname, :string, limit: 128
    add_column :spree_users, :avatar, :string, limit: 128
    add_column :spree_users, :access_token, :string, limit: 128
  end
end
