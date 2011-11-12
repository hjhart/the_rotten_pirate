require 'echoe'
Echoe.new('the_rotten_pirate', '0.1.0') do |p|
  p.description = "An automated torrent downloader from rotten tomatoes/the pirate bay"
  p.url = "http://www.github.com/hjhart/the_rotten_pirate"
  p.author = "James Hart"
  p.email = "hjhart@gmail.com"
  p.ignore_pattern = ["tmp/**/*", "spec/**/*", "Gemfile*"]
  # p.development_dependencies = ['nokogiri', 'hpricot']
end

task :default => :console

task :console do
  sh "irb -rubygems -r ./lib/torrent_api.rb"
end
