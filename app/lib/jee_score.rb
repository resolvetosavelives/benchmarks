class JeeScore < Score
  def initialize(val)
    super(val)
  end

  def score
    return @value
  end

  def score=(val)
    @value = val
  end
end
