class DeleteDetsFromDetail < ActiveRecord::Migration
  def change
  	remove_column :details, :details
  	remove_column :details, :detail1
  end
end
