
class AlterSecureStatusToDetails < ActiveRecord::Migration
  def change
  	remove_column :details, :secure
  	add_column :details, :status, :string, :default => "inapp" # when in app = inapp, after splitting= split, after both dropbox and google = safe
  end
end
