class AddDisplaySettingsToDeck < ActiveRecord::Migration[8.1]
  def change
    add_column :decks, :show_pinyin, :boolean, default: true, null: false
    add_column :decks, :lines_per_slide, :integer, default: 4, null: false
  end
end
