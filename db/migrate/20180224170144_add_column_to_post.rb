class AddColumnToPost < ActiveRecord::Migration[5.1]
  def change
  	add_column :posts, :owner_id, :integer
  end
end
