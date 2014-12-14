class AddCloudIndiToDetails < ActiveRecord::Migration
  def change
  	add_column :details, :dropbox, :string , :default => "No"
  	add_column :details, :google, :string , :default => "No"
  	add_column :details, :split1, :string 
  	add_column :details, :split2, :string 
  end
end
