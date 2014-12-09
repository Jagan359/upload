class DeleteFlagWrongFromDetail < ActiveRecord::Migration
  def change
  	remove_column :details, :secure
  end
end
