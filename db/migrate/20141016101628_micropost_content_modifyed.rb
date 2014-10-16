class MicropostContentModifyed < ActiveRecord::Migration
  def change
    change_column :microposts, :content, :string,[limit: 450, null: false]
  end
end
