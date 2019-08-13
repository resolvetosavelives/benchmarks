class SparScale
  attr_accessor :score
  def initialize(params)
    score = params[:score]
    value = params[:value]
    if score
      @score = score
    elsif value
      @score = Score.new (value / 20)
    else
      raise ArgumentError
    end
  end

  def value
    @score.value * 20
  end

  def value=(val)
    @score.value = val / 20
  end
end
