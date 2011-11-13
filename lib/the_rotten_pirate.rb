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
    @l = ForkLogger.new 
  end
  
  def self.execute
    
    config = YAML.load(File.open('config.yml').read)
    captain = TheRottenPirate.new
    output = captain.instance_variable_get(:@l)
    captain.gather_and_filter_dvds config
    
    full_analysis_results = []
    torrents_to_download = []
    
    captain.summarize_process_to_output
        
    captain.dvds.each do |dvd|
      output.puts "*" * 80
      output.puts "Searching for #{dvd["Title"]}"
      output.puts "*" * 80
      search = PirateBay::Search.new Download.clean_title(dvd["Title"])
      results = search.execute
      output.puts "Found #{results.size} results from the pirate bay."
      
      next if results.empty?
      
      if config["comments"]["analyze"]
        num_to_analyze = config["comments"]["num_to_analyze"]
        quality_level = config["comments"]["quality"] == "low" ? :init : :full
        output.puts "Processing #{[num_to_analyze, results.size].min} torrent pages for comments (as configured)."        
        
        analysis_results = captain.analyze_results results, num_to_analyze, quality_level
        analysis_results = analysis_results.sort_by { |r| -(r[:video][:rank]) }
        
        torrents_to_download << { :link => analysis_results.first[:link], :title => dvd["Title"] }
        full_analysis_results << analysis_results
      else
        torrents_to_download << { :link => results.first.link, :title => dvd["Title"] }
      end
    end
    
    YAMLWriter.new({ :full_analysis_results => full_analysis_results, :links_to_download => torrents_to_download }).write
    
    torrents_to_download.each do |download|
      output.puts "Starting the download for #{download[:title]}"
      if Download.torrent_from_url download[:link]
        Download.insert download[:title] 
        output.puts "Download successfully started."
      else
        output.error "Download failed while starting."
      end
    end

    output.puts "Done!"    
    output.puts "Downloaded a total of #{torrents_to_download.size} torrents"
  end
  
  def analyze_results results, num_to_analyze, quality_level
    results = results[0,num_to_analyze].map do |result|
      url = "http://www.thepiratebay.org/torrent/#{result.id}/"
      html = open(url).read
      p = PirateBay::Details.new html, quality_level
      @l.puts "Fetching comments results from #{url}"
      { 
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
    end
  end
  
  def gather_and_filter_dvds config
    @l.puts "Searching..."
    fetch_new_dvds

    @l.puts "Filtering..."
    filter_percentage config["filter_out_less_than_percentage"] if config["filter_out_less_than_percentage"]
    filter_out_non_certified_fresh if config["filter_out_non_certified_fresh"]
    filter_out_already_downloaded if config["filter_out_already_downloaded"]
  end
  
  def summarize_process_to_output 
    @l.puts "*" * 80
    @l.puts "Attempting to download the following titles: "
    @l.puts dvds.map { |dvd| dvd["Title"] }
    @l.puts "*" * 80
  end
  
  def filter_out_already_downloaded
    @dvds = dvds.reject { |f| Download.exists? f["Title"] }
  end
  
  def filter_out_non_certified_fresh
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

