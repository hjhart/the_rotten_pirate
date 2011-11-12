require 'fork_logger'
require 'awesome_print'
require 'yaml'
require 'download'
require 'torrent_api'

class TheRottenPirate
  def initialize
    @dvds = nil
  end
  
  def self.execute
    Logger.new
    
    trp = TheRottenPirate.new
    trp.fetch_new_dvds
    config = YAML.load(File.open('config.yml').read)
    trp.filter_percentage config["filter_out_less_than_percentage"] if config["filter_out_less_than_percentage"]
    trp.filter_out_non_certified if config["filter_out_non_certified"]
    trp.filter_out_already_downloaded if config["filter_out_already_downloaded"]
    
    trp.dvds.each do |dvd|
      puts "***" * 80
      puts "Searching for #{dvd["Title"]}"
      puts "***" * 80
      search = PirateBay::Search.new Download.clean_title(dvd["Title"])
      ap results = search.execute
      
      if config["comments"]["analyze"]
        
        results_to_analyze = config["comments"]["results_to_analyze"]
        
        if config["comments"]["quality"] == "low"
          comment_quality = :init
        else
          comment_quality = :full
        end
        
        results = results[0,results_to_analyze].map do |result|
          url = "http://www.thepiratebay.org/torrent/#{result.id}/"
          html = open(url).read
          p = PirateBay::Details.new html, comment_quality
          puts "Fetching results"
          result = { 
            :seeds => result.seeds, 
            :size => result.size, 
            :name => result.name, 
            :video => p.video_quality_average, 
            :audio => p.audio_quality_average, 
            :url => url,
            :link => result.link
          } 
          puts "Results: #{result}"
          result
        end
      end
    end
  end
  
  def filter_out_already_downloaded
    @dvds = dvds.reject { |f| Download.exists? f["Title"] }
  end
  
  def filter_out_non_certified
    @dvds = dvds.select { |f| f["CertifiedFresh"] == "1" }
  end

  def filter_percentage threshold
    @dvds = dvds.select { |f| f["NumTomatometerPercent"].to_i >= threshold }
  end
  
  def dvds
    @dvds || fetch_new_dvds
  end
  
  def fetch_new_dvds
    require 'open-uri'
    text = open('http://www.rottentomatoes.com/syndication/tab/new_releases.txt').read
    @dvds = TheRottenPirate.extract_new_dvds text
  end
  
  def self.extract_new_dvds text
    headers = []
    dvds = []
    
    text.strip.split("\n").each_with_index do |row, row_index|
      dvd = {} unless row_index == 0
      row.split("\t").each_with_index do |field, header_index|
        field.chomp!
        if row_index == 0
          headers << field
        else
          dvd[headers[header_index]] = field
        end
      end
      dvds << dvd unless row_index == 0
    end  
    dvds
  end
end

