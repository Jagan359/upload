class AddFlagToDetail < ActiveRecord::Migration
  def change
  	add_column :details, :secure, :boolean
  end
end
