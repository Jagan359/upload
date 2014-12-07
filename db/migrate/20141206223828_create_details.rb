class CreateDetails < ActiveRecord::Migration
  def change
    create_table :details do |t|
      t.string :email
      t.string :file_name
      t.string :detail1
      t.string :details

      t.timestamps
    end
  end
end
