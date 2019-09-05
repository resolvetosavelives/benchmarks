class ActivityMap
  def initialize(m)
    @m = m
  end

  def benchmarks
    @m.keys.map { |benchmark_id_str| BenchmarkId.from_s benchmark_id_str }.sort
  end

  def capacities
    benchmarks.map(&:capacity)
  end

  def capacity_benchmarks(capacity_id_str)
    capacity_id = Integer(capacity_id_str)
    @m.keys.map do |benchmark_id_str|
      BenchmarkId.from_s benchmark_id_str
    end.filter { |benchmark_id| benchmark_id.capacity == capacity_id }.sort
  end

  def capacity_activities(capacity_id_str)
    capacity_id = Integer(capacity_id_str)
    capacity_benchmarks(capacity_id).reduce({}) do |acc, benchmark_id|
      acc[benchmark_id.to_s] = benchmark_activities(benchmark_id)
      acc
    end
  end

  def benchmark_activities(benchmark_id)
    @m[benchmark_id.to_s]
  end
end
