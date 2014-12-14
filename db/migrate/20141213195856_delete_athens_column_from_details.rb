class DeleteAthensColumnFromDetails < ActiveRecord::Migration
  def change
  	remove_column :details, :dropbox_access_code
  	remove_column :details, :google_access_code
  end
end
