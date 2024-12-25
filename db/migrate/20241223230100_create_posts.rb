class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.text :content
      t.integer :parent_post_id

      t.timestamps
    end
  end
end