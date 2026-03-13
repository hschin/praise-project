class CreateThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :themes do |t|
      t.string  :name,             null: false
      t.string  :source,           null: false, default: "custom"
      t.string  :background_color, default: "#000000"
      t.string  :text_color,       default: "#ffffff"
      t.string  :font_size,        default: "medium"
      t.string  :unsplash_url
      t.bigint  :deck_id
      t.timestamps
    end
    add_foreign_key :themes, :decks, on_delete: :nullify
  end
end
