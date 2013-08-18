class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :starter_user_id
      t.integer :with_user_id

      t.timestamps
    end
  end
end
