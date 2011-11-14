task :default => :console

desc "Loads up a console environment"
task :console do
  exec "irb -I lib -r the_rotten_pirate"
  
  sh "irb -rubygems -r lib/the_rotten_pirate.rb"
end

desc "Creates the initial database for storing movie downloads"
task :init_db do
  require "sequel"
  
  FileUtils.mkdir_p('db')
  DB = Sequel.sqlite('db/downloads.sqlite')
  
  DB.create_table :downloads do
    primary_key :id
    String :name
  end
end

desc "This task loads the config file, fetches the rotten tomatoes feed, and downloads torrent files."
task :execute do
  $:.push 'lib'
  require 'the_rotten_pirate'
  TheRottenPirate.execute
end