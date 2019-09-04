class BenchmarkId
  attr_reader :capacity_id, :indicator_id

  def initialize(capacity_id, indicator_id)
    @capacity_id = capacity_id
    @indicator_id = indicator_id
  end

  def self.from_s(val)
    c_str, i_str = val.split('.')
    raise InvalidArgumentError if c_str.nil? || i_str.nil?

    BenchmarkId.new (Integer c_str), (Integer i_str)
  end

  def to_s
    "#{@capacity_id}.#{@indicator_id}"
  end

  def ==(other)
    @capacity_id == other.capacity_id && @indicator_id == other.indicator_id
  end

  def <=>(other)
    if @capacity_id == other.capacity_id
      @indicator_id <=> other.indicator_id
    else
      @capacity_id <=> other.capacity_id
    end
  end
end
