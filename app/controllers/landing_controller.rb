class CountryName
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

class LandingController < ApplicationController
  def show
    assessments = Assessment.all
    @selectables =
      assessments.reduce({}) do |acc, a|
        acc[a[:country]] = [] unless acc[a[:country]]
        acc[a[:country]].push(a[:assessment_type])
        acc
      end

    @countries = @selectables.keys.sort.map { |c| CountryName.new(c) }
  end
end
