class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :userid
      t.string :password
      t.string :nickname
      t.string :introduction
      t.string :favorite_genre

      t.timestamps
    end
  end
end
