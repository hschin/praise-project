class CreateDeckSongs < ActiveRecord::Migration[8.1]
  def change
    create_table :deck_songs do |t|
      t.references :deck, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.integer :position
      t.string :key
      t.jsonb :arrangement

      t.timestamps
    end
  end
end
