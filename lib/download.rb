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
  
end
