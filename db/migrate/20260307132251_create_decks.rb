class CreateDecks < ActiveRecord::Migration[8.1]
  def change
    create_table :decks do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.string :title
      t.text :notes

      t.timestamps
    end
  end
end
