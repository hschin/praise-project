class CreateSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :slides do |t|
      t.references :deck_song, null: false, foreign_key: true
      t.references :lyric, null: false, foreign_key: true
      t.integer :position
      t.text :content

      t.timestamps
    end
  end
end
