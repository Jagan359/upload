class AddKeysToDetail < ActiveRecord::Migration
  def change
  	add_column :details, :key1, :text
  	add_column :details, :key2, :text
  end
end
