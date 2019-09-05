class ActivityMap
  def initialize(m)
    @m = m
  end

  def benchmarks
    @m.keys.map { |k| BenchmarkId.from_s k }.sort
  end

  def capacities
    benchmarks.map(&:capacity)
  end

  def capacity_benchmarks(capacity)
    capacity_ = Integer(capacity)
    @m.keys.map { |k| BenchmarkId.from_s k }.filter do |k|
      k.capacity == capacity_
    end.sort
  end

  def capacity_activities(capacity)
    capacity_ = Integer(capacity)
    capacity_benchmarks(capacity_).reduce({}) do |acc, benchmark_id|
      acc[benchmark_id.to_s] = benchmark_activities(benchmark_id)
      acc
    end
  end

  def benchmark_activities(benchmark_id)
    @m[benchmark_id.to_s]
  end
end
