class AddThemeToDecks < ActiveRecord::Migration[8.1]
  def change
    add_reference :decks, :theme, foreign_key: { to_table: :themes, on_delete: :nullify }, null: true
  end
end
