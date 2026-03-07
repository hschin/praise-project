class MakeSlidesLyricIdNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :slides, :lyric_id, true
    remove_foreign_key :slides, :lyrics
    add_foreign_key :slides, :lyrics, on_delete: :nullify
  end
end
