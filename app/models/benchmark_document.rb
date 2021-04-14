class BenchmarkDocument
  attr_reader :technical_areas, :indicators, :actions

  def initialize
    @technical_areas =
      BenchmarkTechnicalArea.includes(
        { benchmark_indicators: { actions: :reference_library_documents } }
      ).all
    @indicators = @technical_areas.map(&:benchmark_indicators).flatten
    @actions = @indicators.map(&:actions).flatten
  end
end
