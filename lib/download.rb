require 'sequel'

class Download
  def self.connection
    Sequel.sqlite('db/downloads.sqlite')
  end
  
  def self.all
    connection[:downloads]
  end
  
  def self.add_youtube_url name, url, thumbnail_url = nil
    db = connection
    find_by_name(name).update(:youtube_url => url, :thumbnail_url => thumbnail_url)
  end

  def self.find_by_name(name)
    connection[:downloads].filter(:name => name)
  end

  def self.has_youtube_url? name
    db = connection
    movie = find_by_name(name).first
    movie[:youtube_url] != nil
  end

  def self.exists? name
    db = connection
    !!(db[:downloads].filter(:name => name).first)
  end
  
  def self.insert name
    db = connection
    db[:downloads].insert(:name => name)
  end
  
  def self.delete name
    connection[:downloads].filter(:name => name).delete
  end
  
  def self.clean_title movie_title
    movie_title.gsub(/-/, '')
  end
  
  def self.download_directory
    config = YAML.load(File.open('config/config.yml').read)
    download_dir = config["download_directory"] || 'tmp/torrent'
    dirs = download_dir.strip.split('/')
    # This converts any relative home directories to one ruby likes better (osx only probably)
    dirs.map { |dir| dir == "~" ? Dir.home : dir } 
  end
  
  def self.torrent_from_url url
    require 'net/http'
    
    
    torrent_filename_match = url.match(/.*\/(.*)/)
    torrent_name = torrent_filename_match.nil? ? "tmp.torrent" : torrent_filename_match[1]
    torrent_domain, torrent_uri = url.gsub(/https?:\/\//, '').split('.se')
    torrent_domain += '.se'
    
    FileUtils.mkdir_p File.join(self.download_directory)
    filename = File.join(self.download_directory, torrent_name)
    Net::HTTP.start(torrent_domain) do |http| 
       resp = http.get(torrent_uri)
       open(filename, "wb") { |file| file.write(resp.body) }
    end
  end
end
