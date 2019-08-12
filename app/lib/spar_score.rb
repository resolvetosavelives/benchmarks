class SparScore < Score
  def initialize(val)
    super(val)
  end

  def score
    @value * 20
  end

  def score=(val)
    @value = val / 20
  end
end
