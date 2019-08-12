class Score
  def initialize(val)
    raise RangeError unless 1 <= val && val <= 5
    @value = val
  end

  def value
    return @value
  end

  def value=(val)
    raise RangeError unless 1 <= val && val <= 5
    @value = val
  end

  def ==(rside)
    @value == rside.value
  end

  def +(num)
    return self.class.new [@value + num, 5].min
  end
end
