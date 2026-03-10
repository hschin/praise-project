class AddImportColumnsToSongs < ActiveRecord::Migration[8.1]
  def change
    add_column :songs, :import_status, :string, default: "pending", null: false
    add_column :songs, :import_step, :string
  end
end
