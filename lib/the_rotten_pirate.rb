require 'awesome_print'
require 'yaml'
require 'download'

class TheRottenPirate
  def initialize
    @dvds = nil
  end
  
  def self.execute
    trp = TheRottenPirate.new
    trp.fetch_new_dvds
    config = YAML.load(File.open('config.yml').read)
    trp.filter_percentage config["filter_out_percentage"] if config["filter_out_percentage"]
    trp.filter_out_non_certified if config["filter_out_non_certified"]
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

