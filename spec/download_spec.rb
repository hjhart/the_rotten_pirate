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

    describe "clean_title" do
        it "should remove any minus signs" do
            clean_title = Download.clean_title "Harry Potter and the Deathly Hallows - Part 2"
            clean_title.should == "Harry Potter and the Deathly Hallows  Part 2"
        end
    end

    describe "torrent_from_url" do
        it "should be able to download movies with square brackets in it's name" do
            lambda {
                Download.torrent_from_url "http://torrents.thepiratebay.org/6581033/Bad_Teacher[2011]R5_Line_XviD-ExtraTorrentRG.6581033.TPB.torrent"
            }.should_not raise_error
        end
    end

    describe "delete" do
        it "should delete the download of the same name" do
            Download.insert("Movie Title").should be_true
            Download.exists?("Movie Title").should be_true
            Download.delete("Movie Title").should eq 1
            Download.delete("Movie Title").should eq 0
        end
    end
end

