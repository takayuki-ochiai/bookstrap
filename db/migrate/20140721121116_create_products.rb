class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.string :genre
      t.string :link

      t.timestamps
    end
    add_index :products, :title
    add_index :products, :genre
  end
end
