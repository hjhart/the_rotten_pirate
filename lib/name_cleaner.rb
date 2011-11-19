class NameCleaner
  attr_accessor :raw_name, :clean_name
  
  def initialize(raw_name)
    @raw_name = raw_name
    @clean_name = raw_name
  end
  
  def clean_punctuation
    punctuation_to_remove = /[\.\[\]\(\)-]/
    @clean_name = @clean_name.gsub(punctuation_to_remove, " ")
  end
  
  def remove_release_year
    @clean_name = @clean_name.gsub(release_year.to_s, "")
  end

  ["filetype", "urls"].each do |method| 
    define_method "remove_#{method}" do
      extractions = Array(self.send(method))
      extractions.each do |extraction|
        @clean_name = @clean_name.gsub(extraction, "")    
      end
    end      
  end
  
  # def remove_filetype
  #   extractions = Array(filetype)
  #   extractions.each do |extraction|
  #     @clean_name = @clean_name.gsub(extraction, "")    
  #   end
  # end
  # 
  # def remove_urls
  #   extractions = Array(urls)
  #   extractions.each do |extraction|
  #     @clean_name = @clean_name.gsub(extraction, "")    
  #   end    
  # end
  
  ["video_types", "release_groups"].each do |method|
    remove_method_name = :"remove_#{method}"
    terms_method_name = :"#{method}_terms"
    
    define_method remove_method_name do
      extraction_indices = Array(self.send(method))
      extraction_indices.each do |extraction_index| 
        term = NameCleaner.send(terms_method_name).at(extraction_index)
        @clean_name = @clean_name.gsub(Regexp.new(term[:name], term[:modifier]), "")
      end
    end
  end
  
  def remove_whitespace
    @clean_name = @clean_name.gsub(/\s+/, " ")
    @clean_name = @clean_name.strip
  end
  
  def clean
    remove_release_year
    remove_video_types
    remove_filetype
    remove_release_groups
    remove_urls
    clean_punctuation
    remove_whitespace
  end
  
  def release_year
    year_matches = @raw_name.scan(/(\d{4})/).flatten
    two_years_from_now= Time.now.strftime("%Y").to_i + 2

    year_matches = year_matches.map { |year_match|
      year = year_match.to_i
    }.select { |year_match|
      (1895..two_years_from_now).include? year_match
    }
    
    year_matches.first if year_matches.size == 1
  end

  def self.video_types_terms
    [
      { :name => "dvdrip", :modifier => Regexp::IGNORECASE },
      { :name => "xvid", :modifier => Regexp::IGNORECASE }, 
      { :name => "720p", :modifier => Regexp::IGNORECASE }, 
      { :name => "x264", :modifier => Regexp::IGNORECASE }, 
      { :name => "brrip", :modifier => Regexp::IGNORECASE }, 
      { :name => "bdrip", :modifier => Regexp::IGNORECASE }, 
      { :name => "Widescreen", :modifier => Regexp::IGNORECASE }, 
      { :name => "1080p", :modifier => Regexp::IGNORECASE }, 
      { :name => "aac", :modifier => Regexp::IGNORECASE }, 
      { :name => "5.1", :modifier => Regexp::IGNORECASE }, 
      { :name => "ac3", :modifier => Regexp::IGNORECASE }, 
      { :name => "TS", :modifier => nil }, 
      { :name => "scr", :modifier => Regexp::IGNORECASE }, 
      { :name => "rerip", :modifier => Regexp::IGNORECASE }
    ]
  end
  
  def video_types
    video_type = []
    
    NameCleaner.video_types_terms.each_with_index do |term, index|
      regexp = term[:name]
      modifier = term[:modifier]
      video_type << index if @raw_name.match Regexp.new regexp, modifier # case insensitive
    end
    
    video_type
  end
  
  def self.release_groups_terms
    [
      { :name => "NOVA", :modifier => nil },
      { :name => "TWiZTED", :modifier => nil },
      { :name => "Stealthmaster", :modifier => nil },
      { :name => "DUBBY", :modifier => nil },
      { :name => "DoNE", :modifier => nil },
      { :name => "TARGET", :modifier => nil },
      { :name => "Feel-Free", :modifier => nil },
      { :name => "MAXSPEED", :modifier => nil },
      { :name => "1337x", :modifier => nil },
      { :name => "Dita496", :modifier => nil },
      { :name => "AbSurdiTy", :modifier => nil },
      { :name => "dxva", :modifier => nil },
      { :name => "V3nDetta", :modifier => nil },
      { :name => "ExtraTorrentRG", :modifier => nil },
      { :name => "GHZ", :modifier => nil },
      { :name => "AMIABLE", :modifier => nil },
      { :name => "honchorella", :modifier => nil },
      { :name => "MRShanku", :modifier => nil },
      { :name => "Silver RG", :modifier => nil },
      { :name => "ArtSubs", :modifier => nil },
      { :name => "HORiZON", :modifier => nil },
      { :name => "ZJM", :modifier => nil },
      { :name => "PSiG", :modifier => nil },
      { :name => "UsaBit.com", :modifier => nil },
      { :name => "STB", :modifier => nil },
      { :name => "iLG", :modifier => nil },
      { :name => "UnKnOwN", :modifier => nil },
      { :name => "HDLiTE", :modifier => nil },
      { :name => "LPD", :modifier => nil },
      { :name => "Hiest-1337x", :modifier => nil },
      { :name => "aLeX", :modifier => nil },
      { :name => "aXXo", :modifier => nil },
      { :name => "NLT", :modifier => nil },
      { :name => "NeDiVx", :modifier => nil },
      { :name => "PSYCHD", :modifier => nil },
      { :name => "N3WS", :modifier => nil },
    ]
  end
  
  def release_groups
    release_groups = []
    
    NameCleaner.release_groups_terms.each_with_index do |group, index|
      regexp = group[:name]
      modifier = group[:modifier]
      release_groups << index if @raw_name.match Regexp.new regexp #, modifier
    end
    
    release_groups
  end
    
  def filetype
    filetypes = ["avi", "mp4"]
    filetypes.find do |filetype| 
      regexp = Regexp.new "\.#{filetype}"
      @raw_name.match regexp 
    end
  end
  
  def urls
    url_regex = /((https?:\/\/)?(www.)\w+\.(\w+\.)?\w{2,3})/
    urls = @raw_name.scan(url_regex)
    urls.map { |url| url[0] }
  end
end

#  A.Better.Life.LIMITED.DVDRip.XviD-TWiZTED
#  Aladdin[1992]DvDrip[Eng]-Stealthmaster.avi
#  Attack.The.Block.DVDRip.XviD-DoNE
#  Austin Powers International Man of Mystery 1997.720p.x264.BRRip.GokU61
#  Beginners.2010.LIMITED.BDRip.XviD-TARGET
#  Bridesmaids [2011] UNRATED DVDRip XviD-DUBBY
#  Bridesmaids.2011.BRRip.XviD.Ac3.Feel-Free.avi.part
#  Captain America The First Avenger (2011) DVDRip XviD-MAXSPEED
#  Cars 2 (2011) DVDRip XviD-MAXSPEED
#  District 9 (2009) DVDRip XviD-MAXSPEED www.torentz.3xforum.ro.avi
#  DodgeBall [2004] [DVDRip XviD] [1337x]-Dita496
#  Donnie.Darko.Directors.Cut.DVDRip.Xvid.2001-tots.avi
#  Everything.Must.Go.2010.BRRiP.XviD.AbSurdiTy
#  Fast Five[2011]BDRip XviD-ExtraTorrentRG.avi
#  Finding Nemo (2003) Widescreen DVDrip V3nDetta.avi
#  GLADIATOR[2000]DvDrip-GHZ
#  Hall Pass 2011 BRRiP XviD AbSurdiTy
#  Hanna.2011.DVDRip.XviD-AMIABLE
#  Harry Potter And The Deathly Hallows Pt1 2010 BRRip 1080p x264 AAC - honchorella (Kingdom Release)
#  Harry Potter and the Deathly Hallows Part 1[2010]DVDRip XviD-ExtraTorrentRG
#  Harry Potter and the Deathly Hallows Part 2 720p BRRip AAC 5.1- MRShanku - Silver RG
#  Incendies.2010.DVDRip.XviD.AC3.HORiZON-ArtSubs
#  Kung Fu Panda 2 (2011) DVDSCR XviD-ZJM.avi
#  Melancholia.2011.DVDRiP.XViD-PSiG
#  Pirates of the Caribbean On Stranger Tides (2011) DVDRip XviD-MAXSPEED
#  Rare.Exports.A.Christmas.Tale.2010.DVDRIP.XVID-STB.[UsaBit.com].avi
#  The.Triplets.of Belleville..2011.TS.XviD-NOVA.avi
#  Somewhere.2010.DVDRip.XviD-iLG
#  Submarine 2011 DVDRip Xvid UnKnOwN
#  Submarine.2011.720p.BDRip.x264.AC3.dxva-HDLiTE
#  Super 8[2011]DVDScr XviD-ExtraTorrentRG
#  Tabloid.2010.LiMiTED.DVDRip.XviD-LPD
#  Team America.avi
#  The Departed (2006)
#  The Guard (2011) DivX  [Hiest-1337x].avi.part
#  The Tree of Life 2011 (Eng)
#  The.Great.Buck.Howard.2008.LiMiTED.DVDRip.XviD-HNR.[www.FilmsBT.com]
#  The.Triplets.of Belleville.2003.DVDRip-aLeX
#  Transsiberian[2008]DvDrip-aXXo
#  True Grit (2011) SCR NL Sub NLT-Release
#  True Grit[2010]BRRip XviD-ExtraTorrentRG
#  Win.Win.2011.ENG.HDRip.avi
#  Winnie.the.Pooh.RERIP.DVDRip.XviD-NeDiVx
#  X-Men First Class[2011]BRRip XviD-ExtraTorrentRG
#  [ UsaBit.com ] - Rare.Exports.A.Christmas.Tale.2010.LIMITED.BDRip.XviD-PSYCHD
#  [ www.Torrenting.com ] - A.Better.Tomorrow.2010.DVDRip.XviD-N3WS
#  [ www.Torrenting.com ] - Beats.Rhymes.and.Life.The.Travels.of.a.Tribe.Called.Quest.2011.LIMITED.DOCU.BDRip.XviD-PSYCHD
#  brian.regan.i.walked.on.the.moon.2004.xvid
