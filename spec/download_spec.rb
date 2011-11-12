require 'the_rotten_pirate'

describe Download do
  describe "exists?" do
    before do
      db = Download.connection
      @dataset = db[:downloads]
      @dataset.insert(:name => 'Movie Title')
    end
    
    after do
      @dataset.filter(:name => 'Movie Title').delete
    end
    
    it "should detect if the download exists in the database" do
      Download.exists?("Movie Title").should be_true
    end
    
    it "should return false if the download doesn't exist in the database" do
      Download.exists?("Movie Poopy").should be_false
    end
  end
  
  describe "insert" do
    after do
      Download.connection[:downloads].filter(:name => 'Movie Title').delete
    end
    
    it "should insert a download into the database" do
      Download.exists?("Movie Title").should be_false
      Download.insert("Movie Title").should be_true
      Download.exists?("Movie Title").should be_true
    end
  end
end
   