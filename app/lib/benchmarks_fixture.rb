class InvalidParameter < Exception; end
class OutOfBounds < Exception; end

class BenchmarksFixture
  def initialize
    @fixture =
      JSON.load File.open './app/fixtures/benchmarks_and_activities.json'
  end

  def activities(benchmark_id, args)
    raise "Unknown benchmark: #{benchmark_id}" unless @fixture[benchmark_id]

    if args[:score] && args[:goal]
      if args[:goal] && ((args[:goal] < 2) || (5 < args[:goal]))
        raise OutOfBounds.new args[:goal]
      end
      if args[:score] && ((args[:score] < 2) || (5 < args[:score]))
        raise OutOfBounds.new args[:score]
      end
      raise InvalidParameter unless args[:score] <= args[:goal]

      return (args[:score] + 1..args[:goal]).reduce([]) do |acc, level|
        acc.concat @fixture[benchmark_id]['capacity'][level.to_s]
        acc
      end
    elsif args[:level]
      if args[:level] && ((args[:level] < 2) || (5 < args[:level]))
        raise OutOfBounds.new args[:level]
      end
      return @fixture[benchmark_id]['capacity'][args[:level].to_s]
    end

    raise InvalidParameter
  end
end
