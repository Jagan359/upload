class AddAuthnsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :google_access_token, :string
  	add_column :users, :dropbox_access_token, :string
  end
end
