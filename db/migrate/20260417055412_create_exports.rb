class CreateExports < ActiveRecord::Migration[8.1]
  def change
    create_table :exports do |t|
      t.bigint :deck_id, null: false
      t.bigint :user_id, null: false
      t.string :event, null: false  # "generated" or "downloaded"

      t.timestamps
    end

    add_index :exports, :deck_id
    add_index :exports, :user_id
    add_index :exports, :created_at
  end
end
