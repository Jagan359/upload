class AddFlagCorrectToDetail < ActiveRecord::Migration
  def change
  	add_column :details, :secure, :boolean, :default => false
  end
end
