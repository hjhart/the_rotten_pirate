class AddISBNColumn < Sequel::Migration
  # For the up, alter the table to add the isbn number.
  def up
    alter_table :downloads do
      add_column :youtube_url, String
      add_column :thumbnail_url, String
    end
  end

  # For the up, alter the table to remove the isbn number.
  def down
    alter_table :downloads do
      drop_column :youtube_url
      drop_column :thumbnail_url
    end
  end
end