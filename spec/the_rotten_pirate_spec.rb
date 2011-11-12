require 'the_rotten_pirate'

describe TheRottenPirate do
  describe "#extract dvd info" do
    it "should extract some dvds given a text file with them" do
      text = File.open(File.join('spec', 'upcoming_dvds.txt'),'r').read
      dvds = TheRottenPirate.extract_new_dvds text
      dvds.first.should == { 
        "MovieID"=>"770687943", 
        "Title"=>"Harry Potter and the Deathly Hallows - Part 2", 
        "URL"=>"http://www.rottentomatoes.com/m/harry_potter_and_the_deathly_hallows_part_2/", 
        "NumTomatometerPercent"=>"96", 
        "TomatometerRating"=>"FRESH", 
        "CertifiedFresh"=>"1", 
        "ModifiedDate"=>"", 
        "ShowtimeURL"=>"", 
        "Description"=>"Thrilling, powerfully acted, and visually dazzling, <em>Deathly Hallows Part II</em> brings the <em>Harry Potter</em> franchise to a satisfying -- and suitably magical -- conclusion."}
    end
  end
    
  describe "#fetch_new_dvds" do
    it "should grab the upcoming dvds text file and then call extract_new_dvds" do
      TheRottenPirate.should_receive(:extract_new_dvds)
      TheRottenPirate.new.fetch_new_dvds
    end
  end
  
  describe "#filter_out_non_certified" do
    it "should not show any non certified movies" do
      dvds = TheRottenPirate.new.filter_out_non_certified
      dvds.each { |dvd| dvd["CertifiedFresh"].should_not eq "0" }
    end
  end
  
  describe "#filter_out_already_downloaded" do
    before do
      Download.insert "The Strange Case Of Angelica"
    end
    
    after do
      Download.connection[:downloads].filter(:name => 'Movie Title').delete
    end
  
    it "should filter out already downloaded movies" do
      trp = TheRottenPirate.new
      trp.filter_out_already_downloaded
      dvds = trp.instance_variable_get(:@dvds)
      dvds.each { |dvd| dvd["Title"].should_not eq "The Strange Case Of Angelica" }
    end
  end
  
  describe "#filter_percentage" do
    it "should filter out anything lower than the parameter" do
      dvds = TheRottenPirate.new
      dvds.fetch_new_dvds
      before = dvds.instance_variable_get(:@dvds)
      filtered_dvds = dvds.filter_percentage(80)
      filtered_dvds.each { |dvd| dvd["NumTomatometerPercent"].to_i.should > 80 }
      after = dvds.instance_variable_get(:@dvds)
      
      before.size.should > after.size
    end
    
    it "should be chainable with non certified" do
      filter = TheRottenPirate.new
      filter.filter_percentage(80)
      eightieth_percentile = filter.instance_variable_get(:@dvds)
      
      filter.filter_out_non_certified
      certified_and_eighteith_percentile = filter.instance_variable_get(:@dvds)
      (eightieth_percentile - certified_and_eighteith_percentile).size.should == 4
    end
    
  end
  
end
            