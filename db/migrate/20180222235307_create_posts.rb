class CreatePosts < ActiveRecord::Migration[5.1]
  def change
  	create_table :posts do |t|
      t.string :name
      t.float :number
      t.float :price_by
      t.integer :user_id
   	end
  end
end
