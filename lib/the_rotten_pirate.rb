require 'fork_logger'
require 'awesome_print'
require 'yaml'
require 'yaml_writer'
require 'download'
require 'torrent_api'
require 'name_cleaner'
require 'rank'

class TheRottenPirate
  def initialize
    @config = YAML.load(File.open('config/config.yml').read)
    @dvds = nil
    @l = ForkLogger.new 
  end
  
  def initialize_download movie_title
    torrent_to_download, full_results = search_for_dvd movie_title
    if torrent_to_download.nil? 
      puts "No results found for #{movie_title}"
      return
    end
    puts "Starting the download for #{movie_title}"
    if Download.torrent_from_url torrent_to_download[:link]
      Download.insert torrent_to_download[:title] 
      puts "Download successfully started."
    else
      exit("Download failed while starting.")
    end
  end
  
  def search_for_dvd(title, full_analysis=[])
    @l.puts "*" * 80
    @l.puts "Searching for #{title}"
    @l.puts "*" * 80
    search = PirateBay::Search.new Download.clean_title(title)
    results = search.execute
    @l.puts "Found #{results.size} results from the pirate bay."
    
    return if results.empty?
    
    if @config["comments"]["analyze"]
      num_to_analyze = @config["comments"]["num_to_analyze"]
      minimum_seeds = @config["comments"]["minimum_seeds"]
      
      quality_level = @config["comments"]["quality"] == "low" ? :init : :full
      @l.puts "Processing #{[num_to_analyze, results.size].min} torrent pages for comments (as configured)."        
      
      analysis_results = analyze_results results, num_to_analyze, quality_level, minimum_seeds
      analysis_results = analysis_results.sort_by { |r| -(r[:video][:rank]) }
      
      [{ :link => analysis_results.first[:link], :title => title }, analysis_results]
    else
      { :link => results.first.link, :title => title }
    end
  end
    
  
  def self.execute

    captain = TheRottenPirate.new
    output = captain.instance_variable_get(:@l)
    captain.gather_and_filter_dvds
    
    full_analysis_results = []
    torrents_to_download = []
    
    captain.summarize_process_to_output
        
    captain.dvds.each do |dvd|
      torrent_to_download, full_analysis_result = captain.search_for_dvd(dvd["Title"])
      torrents_to_download << torrent_to_download unless torrent_to_download.nil?
      full_analysis_results << full_analysis_result unless full_analysis_result.nil?
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
    output.prowl_message "Downloaded #{torrents_to_download.size} movies", torrents_to_download.map{|m| m[:title] }.join(", ")
  end
  
  def analyze_results results, num_to_analyze, quality_level, minimum_seeds
    results = results[0,num_to_analyze].map do |result|
      url = "http://www.thepiratebay.se/torrent/#{result.id}/"

      if result.seeds < minimum_seeds
        @l.puts "Number of seeds are lower than the threshold - not querying for comments."
        construct_result_hash result, url
      else
        html = open(url).read
        details = PirateBay::Details.new html, quality_level
        @l.puts "Fetching comments results from #{url}"
        construct_result_hash result, url, details
      end
    end
  end
  
  def construct_result_hash result, url, details=nil
    if details.nil?
      video_average = 0
      video_sum = 0
      video_votes = 0
      video_rank = 0
    else
      video_average = details.video_quality_average
      video_sum = details.video_quality_score_sum
      video_votes = details.video_scores.size
      video_rank = Rank.new(details.video_scores).score
    end
      
    { 
      :seeds => result.seeds, 
      :size => result.size, 
      :name => result.name, 
      :video => 
        { 
          :average=> video_average, 
          :sum => video_sum,
          :votes => video_votes,
          :rank => video_rank
        },
      :url => url,
      :link => result.link
    } 
  end
  
  def gather_and_filter_dvds
    @l.puts "Searching..."
    fetch_new_dvds

    @l.puts "Filtering..."
    filter_percentage @config["filter_out_less_than_percentage"] if @config["filter_out_less_than_percentage"]
    filter_out_non_certified_fresh if @config["filter_out_non_certified_fresh"]
    filter_out_already_downloaded if @config["filter_out_already_downloaded"]
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

