class RemoveColFromUser < ActiveRecord::Migration
  def change
  	remove_column :users, :google_access_token
  end
end
