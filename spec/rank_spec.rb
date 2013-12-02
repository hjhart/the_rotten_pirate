require_relative '../lib/the_rotten_pirate'

describe Rank do
  describe "initialize" do
    it "should take the scores hash as an initializer" do
      scores_array = [9.0, 9.0, 9.0, 9.0]
      rank = Rank.new scores_array
      scores = rank.instance_variable_get(:@scores)
      scores.should == scores_array
      rank.should_not be_nil
    end
  end

  describe "score" do
    it "should have a higher score if there are more votes (by at least OFFSET) but the average is the same" do
      scores_array = [9.0, 9.0, 9.0, 9.0]
      rank_higher = Rank.new scores_array
      rank_lower = Rank.new [9.0]
      rank_higher.score.should > rank_lower.score
    end

    it "should have a higher ranking if there are 10 9.125's than if there is 2 10s." do
      rank_higher = Rank.new [9.125,9.125,9.125,9.125,9.125,9.125,9.125,9.125]
      rank_lower = Rank.new [10.0, 10.0]
      rank_higher.score.should > rank_lower.score
    end
  end

end
