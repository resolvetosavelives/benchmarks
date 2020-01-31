class BenchmarkDocument

  attr_reader :technical_areas, :indicators, :activities

  def initialize
    @technical_areas = BenchmarkTechnicalArea.includes({benchmark_indicators: :activities}).all
    @indicators = @technical_areas.map(&:benchmark_indicators).flatten
    @activities = @indicators.map(&:activities).flatten
  end

end
