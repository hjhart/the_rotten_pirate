class Rank
  BASE = 6
  OFFSET = 2
  
  def initialize scores
    @scores = scores
  end
  
  def score
    return 0.0 if @scores.empty?
    score = @scores.inject{ |sum, score| sum + score }.to_f / @scores.size
    offset = [(@scores.size - Rank::OFFSET), 1 ].max
    score += Math.log(offset, Rank::BASE)
  end
end
