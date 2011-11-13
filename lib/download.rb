require 'sequel'

class Download
  def self.connection
    Sequel.sqlite('db/downloads.sqlite')
  end
  
  def self.exists? name
    db = connection
    !!(db[:downloads].filter(:name => name).first)
  end
  
  def self.insert name
    db = connection
    db[:downloads].insert(:name => name)
  end
  
  def self.clean_title movie_title
    movie_title.gsub(/-/, '')
  end
  
  def self.download_directory
    config = YAML.load(File.open('config.yml').read)
    download_dir = config["download_directory"] || 'tmp/torrent'
    dirs = download_dir.strip.split('/')
    File.join(dirs)
  end
  
  def self.torrent_from_url url
    require 'open-uri'
    begin
      torrent_match = url.match(/.*\/(.*)/)
      torrent_name = torrent_match.nil? ? "tmp.torrent" : torrent_match[1]
      FileUtils.mkdir_p('tmp/torrents')
      filename = File.join("tmp/torrents/#{torrent_name}")
      File.open(filename, 'w') { |f|
        f.write open(url).read
      }
      true
    rescue
      false
    end
    
  end
end
