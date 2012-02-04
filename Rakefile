task :default => :console

desc "Loads up a console environment"
task :console do
  exec "irb -I lib -r the_rotten_pirate"
end

desc "Creates the initial database for storing movie downloads and missing config files"
task :initialize do
  
  require "sequel"
  
  FileUtils.mkdir_p('db')
  DB = Sequel.sqlite('db/downloads.sqlite')
  
  begin
    DB.create_table :downloads do
      primary_key :id
      String :name
    end
    puts "Creating sqlite database..."
  rescue Exception
    puts "Database already exists"
  end
  
  config_templpate = File.join(File.dirname(File.expand_path(__FILE__)), "config", "config.template.yml")
  prowl_template = File.join(File.dirname(File.expand_path(__FILE__)), "config", "prowl.template.yml")
  target_config_file = File.join(File.dirname(File.expand_path(__FILE__)), "config", "config.yml")
  target_prowl_file = File.join(File.dirname(File.expand_path(__FILE__)), "config", "prowl.yml")
  unless File.exists? target_prowl_file
    FileUtils.copy(prowl_template, target_prowl_file) 
    puts "Creating working prowl config file..."
  end
  
  unless File.exists? target_config_file
    FileUtils.copy(config_templpate, target_config_file) 
    puts "Creating working rotten pirate config file..."
  end
end

desc "This task loads the config file, fetches the rotten tomatoes feed, and downloads torrent files."
task :execute do
  $:.push 'lib'
  require 'the_rotten_pirate'
  TheRottenPirate.execute
end

desc "This task loads a file (newline delimited) and downloads each of the movies."
task :download_from_watch_file do
  $:.push 'lib'
  require 'the_rotten_pirate'
  trp = TheRottenPirate.new
  filename = '/Users/jhart/Sites/the_mobile_pirate/movies_to_download.txt'
  File.open(filename, 'r').each do |movie_title|
    
    torrent_to_download, full_results = trp.search_for_dvd movie_title
    if torrent_to_download.nil? 
      puts "No results found for #{movie_title}"
      next 
    end
    puts "Starting the download for #{movie_title}"
    if Download.torrent_from_url torrent_to_download[:link]
      Download.insert torrent_to_download[:title] 
      puts "Download successfully started."
    else
      exit("Download failed while starting.")
    end
  end
  
  File.open(filename, 'w') {} # truncate file
end
  

desc "This task will download a single movie" 

task :download, :movie do |t, args|
  movie = args[:movie]
  
  abort "You must specify a movie to download: rake download[\"The Lion King\"]" if movie.nil?
  
  $:.push 'lib'
  require 'the_rotten_pirate'
  trp = TheRottenPirate.new
  torrent_to_download, full_results = trp.search_for_dvd movie
  puts "Starting the download for #{torrent_to_download[:title]}"
  if Download.torrent_from_url torrent_to_download[:link]
    Download.insert torrent_to_download[:title] 
    puts "Download successfully started."
  else
    exit("Download failed while starting.")
  end
  
end
