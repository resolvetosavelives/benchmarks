class ActivityMap
  def initialize(m)
    #@m = m.transform_keys { |key| BenchmarkId.from_s key }
    @m = m
  end

  def benchmarks
    @m.keys.map { |k| BenchmarkId.from_s k }.sort
  end

  def indicators(capacity)
    @m.keys.map { |k| BenchmarkId.from_s k }.filter do |k|
      k.capacity_id == capacity
    end.sort
  end

  def activities(benchmark_id)
    @m[benchmark_id.to_s]
  end
end
