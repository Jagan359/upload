class AddColumnToDetails < ActiveRecord::Migration
  def change
  	add_column :details, :dropbox_access_code, :string
  	add_column :details, :google_access_code, :string
  end
end
