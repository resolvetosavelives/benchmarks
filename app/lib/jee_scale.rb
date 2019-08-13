class JeeScale
  attr_accessor :score
  def initialize(params)
    score = params[:score]
    value = params[:value]
    if score
      @score = score
    elsif value
      @score = Score.new value
    else
      raise ArgumentError
    end
  end

  def value
    @score.value
  end

  def value=
    @score.value
  end
end
