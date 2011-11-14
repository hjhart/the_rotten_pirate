task :default => :console

desc "Loads up a console environment"
task :console do
  exec "irb -I lib -r the_rotten_pirate"
  
  sh "irb -rubygems -r lib/the_rotten_pirate.rb"
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