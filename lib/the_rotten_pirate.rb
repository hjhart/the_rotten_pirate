require 'fork_logger'
require 'awesome_print'
require 'yaml'
require 'yaml_writer'
require 'download'
require 'torrent_api'
require 'rank'

class TheRottenPirate
  def initialize
    @dvds = nil
  end
  
  def self.execute
    l = ForkLogger.new
    
    trp = TheRottenPirate.new
    trp.fetch_new_dvds
    config = YAML.load(File.open('config.yml').read)
    trp.filter_percentage config["filter_out_less_than_percentage"] if config["filter_out_less_than_percentage"]
    trp.filter_out_non_certified if config["filter_out_non_certified"]
    trp.filter_out_already_downloaded if config["filter_out_already_downloaded"]
    
    dvd_results = []
    downloads = []
    
    trp.dvds.each do |dvd|
      l.puts "***" * 80
      l.puts "Searching for #{dvd["Title"]}"
      l.puts "***" * 80
      search = PirateBay::Search.new Download.clean_title(dvd["Title"])
      l.puts results = search.execute
      
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
          l.puts "Fetching comments results from #{url}"
          result = { 
            :seeds => result.seeds, 
            :size => result.size, 
            :name => result.name, 
            :video => 
              { 
                :average=> p.video_quality_average, 
                :sum => p.video_quality_score_sum,
                :votes => p.video_scores.size,
                :rank => Rank.new(p.video_scores).score
              },
            :audio => 
              { 
                :average=> p.audio_quality_average, 
                :sum => p.audio_quality_score_sum,
                :votes => p.audio_scores.size,
                :rank => Rank.new(p.audio_scores).score
              },
            :url => url,
            :link => result.link
          } 
          l.puts "Results: #{result.inspect}"
          result
        end
        results = results.sort_by { |r| -(r[:video][:rank]) }
        downloads << { :link => results.first[:link], :title => dvd["Title"] }
        dvd_results << results
        # now we have an array of results
        # now we need to figure out an algorithm to download the best one?
      end
    end
    
    YAMLWriter.new({ :dvd_results => dvd_results, :links_to_download => downloads }).write
    
    downloads.each do |download|
      l.puts "Starting the download for #{download[:title]}"
      if Download.torrent_from_url download[:link]
        Download.insert download[:title] 
        l.puts "Download successfully started."
      else
        l.puts "Download failed while starting."
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

