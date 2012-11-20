class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.string :name
      t.string :download_url
      t.string :youtube_url
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
