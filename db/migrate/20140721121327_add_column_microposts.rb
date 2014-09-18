class AddColumnMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :product_id, :integer
    add_column :microposts, :emotion, :string
    add_column :microposts, :good, :integer
    add_index :microposts, :product_id
    add_index :microposts, [:user_id, :product_id], unique: true
  end
end
