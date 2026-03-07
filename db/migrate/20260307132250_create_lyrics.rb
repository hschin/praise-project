class CreateLyrics < ActiveRecord::Migration[8.1]
  def change
    create_table :lyrics do |t|
      t.references :song, null: false, foreign_key: true
      t.string :section_type
      t.integer :position
      t.text :content
      t.text :pinyin

      t.timestamps
    end
  end
end
