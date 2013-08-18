class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :conversation_id
      t.text :body
      t.datetime :read_at
      t.datetime :sender_deleted_at
      t.datetime :receiver_deleted_at

      t.timestamps
    end
  end
end
