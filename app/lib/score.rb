class Score
  def initialize(val)
    @value = val
    raise RangeError unless 0 <= @value && @value <= 5
  end

  def value
    return @value
  end

  def value=(val)
    raise RangeError unless 0 <= val && val <= 5
    @value = val
  end

  def ==(rside)
    @value == rside.value
  end

  def <=>(rside)
    if @value < rside.value
      return -1
    elsif @value > rside.value
      return 1
    else
      return 0
    end
  end

  def <=(rside)
    (self <=> rside) < 1
  end
end
