class RemoveColFromDetail < ActiveRecord::Migration
  def change
  	remove_column :details, :key1
  	remove_column :details, :key2
  end
end
