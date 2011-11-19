require 'the_rotten_pirate'

describe NameCleaner do
  describe "#inititalize" do
    it "should take a string and set it to it's raw_name" do
      name = NameCleaner.new "string"
      name.raw_name.should == "string"
    end
  end
  
  describe "#clean_punctuation" do
    it "should get rid of periods and parenthesis" do
       nc = NameCleaner.new("Submarine.2011.720p.BDRip.x264.AC3.dxva-HDLiTE")
       nc.clean_punctuation
       nc.clean_name.should == "Submarine 2011 720p BDRip x264 AC3 dxva HDLiTE"
    end
  end
  
  describe "#remove_release_year" do
    it "should delete it from the clean name" do
      nc = NameCleaner.new("String[2010]")
      nc.remove_release_year
      nc.clean_name.should == "String[]"
    end
  end

  describe "#remove_urls" do
    it "should delete it from the clean name" do
      nc = NameCleaner.new("String www.root.com www.example.com")
      nc.remove_urls
      nc.clean_name.should == "String  "
    end
  end

  describe "#remove_release_groups" do
    it "should delete it from the clean name" do
      nc = NameCleaner.new("String MAXSPEED NOVA")
      nc.remove_release_groups
      nc.clean_name.should == "String  "
    end
  end

  describe "#remove_video_types" do
    it "should delete it from the clean name" do
      nc = NameCleaner.new("String DVDRip BRRip")
      nc.remove_video_types
      nc.clean_name.should == "String  "
    end
  end

  describe "the dynamically generated remove methods" do  
    ["release_year", "video_types", "filetype", "release_groups", "urls"].each do |method|
      it "should respond to remove_#{method}" do
        nc = NameCleaner.new "doesn't matter"
        method = :"remove_#{method}"
        nc.should respond_to method
      end
    end
  end
  
  describe "#release_year" do
    it "should extract any four digit number" do
      NameCleaner.new("String[2010]").release_year.should == 2010
    end
    
    it "should only extract the year if it's an appropriate year (1950 - Next Year)" do
      NameCleaner.new("String[1337]").release_year.should == nil
      NameCleaner.new("String[1894]").release_year.should == nil
      NameCleaner.new("String[1895]").release_year.should == 1895
      NameCleaner.new("String[2050]").release_year.should == nil
    end
    
    it "should only extract the proper four digit number if there are two and one is a year" do
      NameCleaner.new("String[1337]2010").release_year.should == 2010
    end
  end
  
  describe "#video_types" do
    it "should detect if a movie is 720, 1080p, xvid, etc..." do
      NameCleaner.new("Submarine 2011 DVDRip Xvid UnKnOwN").video_types.should =~ [index_of("video_types", "dvdrip"), index_of("video_types", "xvid")]
      NameCleaner.new("Submarine.2011.720p.BDRip.x264.AC3.dxva-HDLiTE").video_types.should =~ [index_of("video_types", "720p"), index_of("video_types", "bdrip"), index_of("video_types", "x264"), index_of("video_types", "ac3")]
    end
    
    it "should not detect a stupid end of word with 'ts', but should detect a Theatrical Screening" do
      NameCleaner.new("Rise.of.the.Planet.of.the.Apes.2011.TS.XviD-NOVA.avi").video_types.should =~ [index_of("video_types", "TS"), index_of("video_types", "xvid")]
      NameCleaner.new("Rare.Exports.A.Christmas.Tale.2010.[UsaBit.com].avi").video_types.should =~ []
    end
  end
  
  describe "#remove_whitespace" do
    it "should remove spaces on both sides" do
      nm = NameCleaner.new "   hallllllelujah    "
      nm.remove_whitespace
      nm.clean_name.should == "hallllllelujah"
    end
    
    it "should switch anything greater than one spaces to one spaces" do
      nm = NameCleaner.new "there was once  many    spaces   between   here"
      nm.remove_whitespace
      nm.clean_name.should == "there was once many spaces between here"
    end
  end
  
  describe "#clean" do
    it "should remove all of the junk. ALL OF IT!" do
      NameCleaner.new("Rise.of.the.Planet.of.the.Apes.2011.TS.XviD-NOVA.avi").clean.should == "Rise of the Planet of the Apes"
      NameCleaner.new("True Grit[2010]BRRip XviD-ExtraTorrentRG").clean.should == "True Grit"
      NameCleaner.new("Submarine.2011.720p.BDRip.x264.AC3.dxva-HDLiTE").clean.should == "Submarine"
      NameCleaner.new("The.Triplets.of Belleville.2011.TS.XviD-NOVA.avi").clean.should == "The Triplets of Belleville"
    end
  end
  
  describe "#filetype" do
    it "should detect the type of video that it is if it looks like a filename" do
      NameCleaner.new("Rise.of.the.Planet.of.the.Apes.2011.TS.XviD-NOVA.avi").filetype.should == 'avi'
    end
  end
  
  describe "#release_groups" do
    it "should detect release groups" do
      NameCleaner.new("Rise.of.the.Planet.of.the.Apes.2011.TS.XviD-NOVA.avi").release_groups.should == [index_of('release_groups', 'NOVA')]
      NameCleaner.new("Cars 2 (2011) DVDRip XviD-MAXSPEED").release_groups.should == [index_of('release_groups', 'MAXSPEED')]
      NameCleaner.new("Beginners.2010.LIMITED.BDRip.XviD-TARGET").release_groups.should == [index_of('release_groups', 'TARGET')]
      NameCleaner.new("Bridesmaids [2011] UNRATED DVDRip XviD-DUBBY").release_groups.should == [index_of('release_groups', 'DUBBY')]
      NameCleaner.new("Bridesmaids.2011.BRRip.XviD.Ac3.Feel-Free.avi.part").release_groups.should == [index_of('release_groups', 'Feel-Free')]
      NameCleaner.new("Captain America The First Avenger (2011) DVDRip XviD-MAXSPEED").release_groups.should == [index_of('release_groups', 'MAXSPEED')]
    end                
  end
  
  describe "#urls" do
    it "should extract any and all urls" do
      NameCleaner.new("District 9 (2009) DVDRip XviD-MAXSPEED www.torrentzalive.com").urls.should == ['www.torrentzalive.com']
    end
    
    it "shouldn't die if no URLs were found" do
      NameCleaner.new("District 9 (2009) DVDRip XviD-MAXSPEED").urls.should == []
    end
  end
end   
    
def index_of(type, string)
  method = :"#{type}_terms"
  terms = NameCleaner.send(method)
  terms.index { |term| term[:name] == string }
end
