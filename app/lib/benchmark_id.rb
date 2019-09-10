# A structured representation of a benchmark id
#
# BenchmarkId objects are sorted first along the lines of capacity id and then
# along the lines of indicator id.
class BenchmarkId
  attr_reader :capacity, :indicator
  def initialize(capacity, indicator)
    @capacity = capacity
    @indicator = indicator
  end

  # Retrieve the capacity ID as a string.
  def capacity_s
    @capacity.to_s
  end

  # Retrieve the indicator ID as a string.
  def indicator_s
    @indicator.to_s
  end

  # Construct a BenchmarkId from a string. The input string must be of the form
  # <number>.<number>, such as "5.10".
  def self.from_s(val)
    c_str, i_str = val.split('.')
    raise InvalidArgumentError if c_str.nil? || i_str.nil?

    BenchmarkId.new (Integer c_str), (Integer i_str)
  end

  # Convert a BenchmarkId into its string representation.
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
