class AddMetadataToSongs < ActiveRecord::Migration[8.1]
  def change
    add_column :songs, :english_title, :string
    add_column :songs, :ccli_number, :string
  end
end
