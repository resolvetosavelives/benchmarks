class BenchmarkId
  attr_reader :capacity, :indicator
  def initialize(capacity, indicator)
    @capacity = capacity
    @indicator = indicator
  end

  def capacity_s
    @capacity.to_s
  end

  def indicator_s
    @indicator.to_s
  end

  def self.from_s(val)
    c_str, i_str = val.split('.')
    raise InvalidArgumentError if c_str.nil? || i_str.nil?

    BenchmarkId.new (Integer c_str), (Integer i_str)
  end

  def to_s
    "#{@capacity}.#{@indicator}"
  end

  def ==(other)
    @capacity == other.capacity && @indicator == other.indicator
  end

  def <=>(other)
    if @capacity == other.capacity
      @indicator <=> other.indicator
    else
      @capacity <=> other.capacity
    end
  end
end
